require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Members

        def self.run
          logger = Identity::Importer.logger
          members = Identity::Importer.connection.run_query(sql)

          email_subscription = Subscription.find(Subscription::EMAIL_SUBSCRIPTION)

          members.each_slice(1000) do |members_data|
            ActiveRecord::Base.transaction do
              new_members = []
              new_member_subscriptions = []
              members_data.each do |member_data|
                data = {
                  name: (member_data['firstname'] or '(none)')+' '+(member_data['lastname'] or '(none)'),
                  email: member_data['email'],
                  created_at: member_data['created_at'].try(:to_datetime),
                  updated_at: member_data['updated_at'].try(:to_datetime)
                }

                member = Member.find_or_initialize_by(email: member_data['email'])
                member.attributes = data

                if member.new_record?
                  new_members << member
                  logger.debug "Importing Member with id #{member.id}"
                elsif member.changed?
                  member.save
                  logger.debug "Updating Member with id #{member.id}"
                end

                if Identity::Importer.configuration.add_email_subscription
                  unless email_subscription.nil?
                    member_subscription = MemberSubscription.find_or_initialize_by(subscription: email_subscription, member: member)
                    if member_subscription.new_record?
                      new_member_subscriptions << member_subscription
                    end
                  end
                end

              end
              Member.import new_members
              MemberSubscription.import new_member_subscriptions
            end
          end
        end

      end
    end
  end
end
