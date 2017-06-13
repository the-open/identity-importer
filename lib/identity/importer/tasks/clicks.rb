require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Clicks

        def self.run(days_young=nil)
          logger = Identity::Importer.logger
          synced_mailings = Mailing.where(recipients_synced: true)
          unless days_young.nil?
            synced_mailings = synced_mailings.where("created_at >= ?", Date.today-days_young.days)
          end

          synced_mailings.each do |mailing|
            last_click = Click.joins(:member_mailing).
                         where(member_mailings: {mailing_id: mailing.id}).
                         order(:created_at).last

            member_mailing_cache = Utils::member_mailing_cache(mailing.id)

            clicks = Identity::Importer.connection.run_query(sql(mailing.external_id, last_click.try(:created_at) || 0))
            clicks_count = 0

            clicks.each_slice(1000) do |click_events|
              new_clicks = []
              ActiveRecord::Base.transaction do
                click_events.each do |click_event|
                  member_mailing_id = member_mailing_cache[click_event['email']]

                  if member_mailing_id.nil?
                    logger.warn "SKIPPED CLICK: Couldn't find MemberMailing with email: #{click_event['email']}, mailing_id: #{mailing.id}"
                    next
                  end

                  timestamp = click_event['timestamp'].to_datetime
                  click = Click.new(
                    member_mailing_id: member_mailing_id,
                    created_at: timestamp,
                    updated_at: timestamp
                  )

                  new_clicks << click
                end
                clicks_count += new_clicks.length
                Click.import new_clicks
              end
            end
            
            if clicks_count > 0
              logger.info "Finished importing clicks. Updating counts for #{mailing.name}"
              update_last_clicks mailing.id
              mailing.update_counts
            else
              logger.info "Finished importing clicks. no changes so not updating counts."
            end
          end
        end

        def self.update_last_clicks mailing_id
          update_mm_sql = %{
    UPDATE member_mailings SET first_clicked = first.created_at
    FROM (SELECT member_mailings.id AS id, MIN(clicks.created_at) AS created_at
          FROM member_mailings JOIN clicks
          ON clicks.member_mailing_id = member_mailings.id
          WHERE member_mailings.mailing_id = #{mailing_id}
          GROUP BY member_mailings.id) first
    WHERE first.id = member_mailings.id and member_mailings.mailing_id = #{mailing_id}

            }
          Click.connection.execute(update_mm_sql)
        end

      end
    end
  end
end
