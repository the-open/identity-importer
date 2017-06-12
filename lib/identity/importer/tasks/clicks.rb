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
                    member_mailing_id: member_mailing.id,
                    created_at: timestamp,
                    update_at: timestamp
                  )

                  new_clicks << click
                end
                Click.import new_clicks
              end
            end
            update_last_clicks mailing.id
            mailing.update_counts
          end
        end

        def update_last_clicks mailing_id
          %{
              UPDATE member_mailings SET first_clicked = MIN(click.created_at)
              FROM  member_mailings, clicks
              WHERE member_mailings.mailing_id = #{mailing_id}
              AND   click.member_mailing_id = member_mailing.id
              GROUP BY member_mailings.id
            }
        end

      end
    end
  end
end
