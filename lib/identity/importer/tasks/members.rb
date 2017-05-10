require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Members

        def self.run
          logger = Identity::Importer.logger

          Padrino.logger.info "Loading member cache"
          got_members = Utils::member_cache
          Padrino.logger.info "Loading member cache done (#{got_members.size} of them)"
          already_added_emails = Set.new
          members = Identity::Importer.connection.run_query(sql)

          email_subscription = Subscription.find(Subscription::EMAIL_SUBSCRIPTION)
          if Identity::Importer.configuration.add_email_subscription and email_subscription.nil?
            email_subscription = Subscription.create! id: Subscription::EMAIL_SUBSCRIPTION
          end

          Padrino.logger.info "Received #{members.count} members from upstream database"

          members.each_slice(1000) do |member_batch|
            Padrino.logger.info "Start importing members batch (of 1000)"
            ActiveRecord::Base.transaction do
              new_members = []
              new_member_subscriptions = []
              member_batch.each do |member_data|
                next if already_added_emails.include? member_data['email']

                member_in_id = got_members[member_data['email']]
                if member_in_id

                  if Identity::Importer.configuration.add_email_subscription
                    # this contact is opt out.
                    # we need to remove the subscription from Identity Id
                    unless member_data['email_subscription'] and
                          not member_in_id[:email_subscription_id].nil?

                      MemberSubscription.find(member_in_id[:email_subscription_id]).delete
                      member_in_id[:email_subscription_id] = nil
                    end

                    if member_data['email_subscription'] and
                      member_in_id[:email_subscription_id].nil?
                      # we have this member but does not have email subscription.
                      # schedule to add it.
                      new_member_subscriptions << MemberSubscription.new(subscription: email_subscription, member_id: member_in_id[:id])
                    end
                  end

                else
                  member = Member.new
                  member.attributes = {
                    first_name: member_data['firstname'],
                    last_name: member_data['lastname'],
                    email: member_data['email'],
                    created_at: member_data['created_at'].try(:to_datetime),
                    updated_at: member_data['updated_at'].try(:to_datetime)
                  }

                  if Identity::Importer.configuration.add_email_subscription
                    if member_data['email_subscription']
                      new_member_subscriptions << MemberSubscription.new(subscription: email_subscription, member: member)
                    end
                  end

                  already_added_emails << member_data['email']
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
