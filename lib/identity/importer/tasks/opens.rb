require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Opens

        def self.run(days_young=nil)
          logger = Identity::Importer.logger
          synced_mailings = Mailing.where(recipients_synced: true)
          unless days_young.nil?
            synced_mailings = synced_mailings.where("created_at >= ?", Date.today-days_young.days)
          end

          synced_mailings.each do |mailing|
            last_open = Open.joins(:member_mailing).
                        where(member_mailings: {mailing_id: mailing.id}).
                        order(:created_at).last

            member_mailing_cache = Utils::member_mailing_cache(mailing.id);

            logger.info "#{mailing.name} last open #{last_open}, members cached (count:  #{member_mailing_cache.size})"

            opens = Identity::Importer.connection.run_query(sql(mailing.external_id, last_open.try(:created_at) || 0))

            opens.each_slice(1000) do |open_events|
              new_opens = []
              ActiveRecord::Base.transaction do
                open_events.each do |open_event|
                  member_mailing_id = member_mailing_cache[open_event['email']]

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
              end
            end
            logger.info "Finished. Updating counts for #{mailing.name}"
            update_last_opens mailing.id
            mailing.update_counts
          end
        end

        def self.update_last_opens mailing_id
          update_mm_sql = %{
    UPDATE member_mailings SET first_opened = first.created_at
    FROM (SELECT member_mailings.id AS id, MIN(opens.created_at) AS created_at
          FROM member_mailings JOIN opens
          ON opens.member_mailing_id = member_mailings.id
          WHERE member_mailings.mailing_id = #{mailing_id}
          GROUP BY member_mailings.id) first
    WHERE first.id = member_mailings.id and member_mailings.mailing_id = #{mailing_id}
            }
          Open.connection.execute(update_mm_sql)
        end

      end
    end
  end
end
