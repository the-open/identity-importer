require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Members

        def self.run(sync_since=nil)
          logger = Identity::Importer.logger

          if sync_since.nil?
            last_member = Member.where(crypted_password: nil).order("created_at desc").first
            sync_since = last_member.try(:created_at) || 0
          end

          Padrino.logger.info "Loading member cache"
          got_members = Utils::member_cache
          Padrino.logger.info "Loading member cache done (#{got_members.size} of them)"
          already_added_emails = Set.new
          members = Identity::Importer.connection.run_query(sql(sync_since))

          email_subscription = Subscription.find(Subscription::EMAIL_SUBSCRIPTION)
          if Identity::Importer.configuration.add_email_subscription and email_subscription.nil?
            email_subscription = Subscription.create! id: Subscription::EMAIL_SUBSCRIPTION
          end

          Padrino.logger.info "Received #{members.count} members from upstream database"

          members.each_slice(1000) do |member_batch|
            Padrino.logger.info "Start importing members batch (of 1000)"
            ActiveRecord::Base.transaction do
              new_members = []
              new_phone_numbers = []
              member_batch.each do |member_data|
                next if already_added_emails.include? member_data['email']

                member_in_id = got_members[member_data['email']]
                if member_in_id.nil?
                  member = Member.new
                  if member.attributes.keys.include?("first_name")
                    member.attributes = {
                      first_name: member_data['firstname'],
                      last_name: member_data['lastname'],
                    }
                  else
                    member.attributes = {
                      name: "#{member_data['firstname']} #{member_data['lastname']}"
                    }
                  end
                  member.attributes = {
                    email: member_data['email'],
                    created_at: member_data['created_at'].try(:to_datetime),
                    updated_at: member_data['updated_at'].try(:to_datetime)
                  }

                  unless member_data['phone_number'].blank?
                    number = Cleanser.cleanse_phone_number(member_data['phone_number'])
                    phone_number = PhoneNumber.find_or_create_by(member_id: member.id, phone: number)
                    if phone_number.valid?
                      new_phone_numbers << phone_number
                    end
                  end

                  new_members << member
                  already_added_emails << member_data['email']
                end
              end
              Member.import new_members
              PhoneNumber.import new_phone_numbers
            end
          end
          Padrino.logger.info "All members imported. Now let's batch create mail subscription for all of them"
          if Identity::Importer.configuration.add_email_subscription
            ActiveRecord::Base.connection.execute %{INSERT INTO member_subscriptions (subscription_id, member_id, created_at, updated_at)
               SELECT #{Subscription::EMAIL_SUBSCRIPTION},m.id,m.created_at,m.created_at FROM members m LEFT JOIN  member_subscriptions ms ON m.id = ms.member_id WHERE ms.id IS NULL;
            }
          end
        end
      end
    end
  end
end
