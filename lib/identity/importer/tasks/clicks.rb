require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Clicks

        def self.run
          logger = Identity::Importer.logger
          synced_mailings = Mailing.where(recipients_synced: true)

          synced_mailings.each do |mailing|
            last_click = Click.joins(:member_mailing).
                         where(member_mailings: {mailing_id: mailing.id}).
                         order(:created_at).last

            clicks = Identity::Importer.connection.run_query(sql(mailing.external_id))

            clicks.each_slice(1000) do |click_events|
              new_clicks = []
              ActiveRecord::Base.transaction do
                click_events.each do |click_event|

                  member = Member.find_by(email: click_event['email'])
                  member_id = member.try(:id) || 1

                  member_mailing = MemberMailing.find_by(member_id: member_id, mailing_id: mailing.id)

                  if member_mailing.nil?
                    logger.warn "SKIPPED CLICK: Couldn't find MemberMailing with member_id: #{member_id}, mailing_id: #{mailing.id}"
                  else
                    click = Click.new(
                      member_mailing_id: member_mailing.id
                    )

                    timestamp = click_event['timestamp'].to_datetime
                    click.created_at = timestamp
                    click.updated_at = timestamp

                    if member_mailing.first_clicked.nil?
                      member_mailing.first_clicked = timestamp
                      member_mailing.save!
                    end

                    if click.new_record?
                      new_clicks << click
                      logger.debug "Importing Click with id #{click.id}"
                    elsif click.changed?
                      click.save!
                      logger.debug "Updating Click with id #{click.id}"
                    end
                  end
                end
                Click.import new_clicks
              end
            end

            mailing.update_counts
          end
        end

      end
    end
  end
end
