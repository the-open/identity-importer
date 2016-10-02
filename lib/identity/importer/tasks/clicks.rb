require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Clicks

        def self.run
          synced_mailings = Mailing.where(recipients_synced: true)

          synced_mailings.each do |mailing|
            click_events = Identity::Importer.connection.run_query(sql(mailing.external_id))

            clicks = []
            ActiveRecord::Base.transaction do
              click_events.each do |click_event|

                member = Member.find_by(email: click_event['email'])
                member_id = member.try(:id) || 1

                member_mailing = MemberMailing.find_by(member_id: member_id, mailing_id: mailing.id)

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

                clicks << click
              end
              Click.import clicks
            end

            mailing.update_counts
          end
        end

      end
    end
  end
end
