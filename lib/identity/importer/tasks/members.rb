require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Members

        def self.run
          logger = Identity::Importer.logger

          got_members = Utils::member_cache
          members = Identity::Importer.connection.run_query(sql)

          email_subscription = Subscription.find(Subscription::EMAIL_SUBSCRIPTION)

          members.each_slice(1000) do |member_batch|
            ActiveRecord::Base.transaction do
              new_members = []
              new_member_subscriptions = []
              member_batch.each do |member_data|
                data = {
                  name: (member_data['firstname'] or '(none)')+' '+(member_data['lastname'] or '(none)'),
                  email: member_data['email'],
                  created_at: member_data['created_at'].try(:to_datetime),
                  updated_at: member_data['updated_at'].try(:to_datetime)
                }

                member_in_id = got_members[member_data['email']]
                if member_in_id
                  # this contact is opt out.
                  # we need to remove the subscription from Identity Id
                  if member_data['is_opt_in'] == 1
                    and not member_in_id[:email_subscription_id].nil?

                    MemberSubscription.find(member_in_id[:email_subscription_id]).delete
                    member_in_id[:email_subscription_id] = nil
                  end

                  if member_data['is_opt_in'] == 0
                    and member_in_id[:email_subscription_id].nil?
                    # we have this member but does not have email subscription.
                    # schedule to add it.
                    new_member_subscriptions << MemberSubscription.new subscription: email_subscription, member_id: member_in_id[:id]
                  end

                else
                  member = Member.new
                  member.attributes = data

                  if member_data['is_opt_out'] == 0
                    new_member_subscriptions << MemberSubscription.new subscription: email_subscription, member_id: member_in_id[:id]
                  end
                end



                if member.new_record?
                  new_members << member
                  logger.debug "Importing Member with email #{member.email}"
                elsif member.changed?
                  member.save
                  logger.debug "Updating Member with email #{member.email}"
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
