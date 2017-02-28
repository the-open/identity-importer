require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Opens

        def self.run
          logger = Identity::Importer.logger
          synced_mailings = Mailing.where(recipients_synced: true)

          synced_mailings.each do |mailing|
            last_open = Open.joins(:member_mailing).
                        where(member_mailings: {mailing_id: mailing.id}).
                        order(:created_at).last
            member_mailing_cache = Member.
                                   joins(:member_mailings).
                                   select('members.id, members.email, member_mailings.id as member_mailing_id').
                                   where(member_mailings: {mailing_id: mailing.id}).
                                   inject({}) do |cache, member|
              cache[member.email] = member.member_mailing_id
              cache
            end
            logger.info "last open #{last_open}, Opens MM cache size #{cache.length}"

            opens = Identity::Importer.connection.run_query(sql, mailing.external_id, last_open.try(:created_at) || 0)

            opens.each_slice(1000) do |open_events|
              new_opens = []
              ActiveRecord::Base.transaction do
                open_events.each do |open_event|
                  member_mailing_id = cache[open_event['email']]

                  if member_mailing_id.nil?
                    logger.warn "SKIPPED OPEN: Couldn't find MemberMailing with email: #{open_event['email']}, mailing_id: #{mailing.id}"
                    next
                  end

                  timestamp = open_event['timestamp'].to_datetime
                  open = Open.new(
                    member_mailing_id: member_mailing_id,
                    created_at: timestamp,
                    updated_at: timestamp
                  )
                  
                  new_opens << open
                end
                Open.import new_opens
                self.update_last_opens
              end
            end
            update_last_opens mailing.id
            mailing.update_counts
          end
        end

        def self.update_last_opens mailing_id
          %{
              UPDATE member_mailings SET first_opened = MIN(open.created_at)
              FROM  member_mailings, opens
              WHERE member_mailings.mailing_id = #{mailing_id}
              AND   open.member_mailing_id = member_mailing.id
              GROUP BY member_mailings.id
            }
        end

      end
    end
  end
end
