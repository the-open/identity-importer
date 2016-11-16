require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Opens

        def self.run
          logger = Identity::Importer.logger
          synced_mailings = Mailing.where(recipients_synced: true)

          synced_mailings.each do |mailing|
            opens = Identity::Importer.connection.run_query(sql(mailing.external_id))

            opens.each_slice(1000) do |open_events|
              new_opens = []
              ActiveRecord::Base.transaction do
                open_events.each do |open_event|

                  member = Member.find_by(email: open_event['email'])
                  member_id = member.try(:id) || 1

                  member_mailing = MemberMailing.find_by(member_id: member_id, mailing_id: mailing.id)

                  if member_mailing.nil?
                    logger.warn "SKIPPED OPEN: Couldn't find MemberMailing with member_id: #{member_id}, mailing_id: #{mailing.id}"
                  else
                    open = Open.new(
                      member_mailing_id: member_mailing.id
                    )

                    timestamp = open_event['timestamp'].to_datetime
                    open.created_at = timestamp
                    open.updated_at = timestamp

                    if member_mailing.first_opened.nil?
                      member_mailing.first_opened = timestamp
                      member_mailing.save!
                    end

                    if open.new_record?
                      new_opens << open
                    elsif open.changed?
                      open.save!
                    end
                  end
                end
                Open.import new_opens
              end
            end

            mailing.update_counts
          end
        end

      end
    end
  end
end
