
module Identity
  module Importer
    module Tasks
      class Optout

        def self.run
          optouts = Identity::Importer.connection.run_query(sql)
          optouts_count = optouts.count
          modified_count = 0
          logger = Identity::Importer.logger

          got_members = Utils::member_cache

          ActiveRecord::Base.transaction do
            optouts.each_with_index do |optout_data, i|
              logger.info "Processing optouts #{i}/#{optouts_count}" if i % 1000 == 0
              # have we got this member on the list?
              known = got_members[optout_data['email']]
              # skip if we don't
              next if known.nil?
              # is this member subscribed on our list?
              if known[:unsubscribed_at].nil?
                # then unsubscribe her
                MemberSubscription.find(known[:email_subscription_id]).
                  update_attributes({
                                      unsubscribed_at: optout_data['created_at'],
                                      unsubscribe_reason: "CiviCRM optout",
                                      permanent: true # be safe.
                                    })
                modified_count += 1
              end
            end
          end
          logger.info "Finished processing optouts, #{modified_count} modified"
        end

      end
    end
  end
end
