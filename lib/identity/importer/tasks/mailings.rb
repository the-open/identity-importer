require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Mailings

        COLUMNS_TO_SELECT = [
          'name',         # a staff-friendly name for this mailing
          'external_id',  # the id of the mailing object in your other system
          'subject',      # the subject line (or lines)
          'body_html',    #
          'body_plain',   #
          'from',         # the fromline
          'created_at',   # when the mailing object was created
          'sent_at',      # when you actually hit send on the mailing
          'scheduled_for',  # when the mailing was scheduled for
          'finished_sending_at', # when the sending job finished
          'send_time',    # sending duration in seconds
          'member_count'  # the actual count (not expected) of mailings sent
        ]

        def self.run
          logger = Identity::Importer.logger
          mailings = Identity::Importer.connection.run_query(sql)

          mailings.each_slice(1000) do |mailings_data|
            ActiveRecord::Base.transaction do
              new_mailings = []
              mailings_data.each do |mailing_data|
                mailing = Mailing.find_or_initialize_by(external_id: mailing_data['external_id'])
                if mailing.new_record?
                  mailing.attributes = mailing_data.select do |column_name, value|
                    COLUMNS_TO_SELECT.include? column_name
                  end
                end

                campaign = Campaign.find_by(controlshift_campaign_id: mailing_data['campaign_id'])

                mailing.campaign_id = campaign.try(:id)
                mailing.recipients_synced = false

                if mailing.new_record?
                  unless mailing.valid?
                    logger.debug "Mailing (external_id=#{mailing.external_id}) invalid! #{mailing.errors.messages}"
                  else
                    new_mailings << mailing
                  end
                  logger.debug "Importing Mailing with subject #{mailing.subject}"
                elsif mailing.changed?
                  mailing.save!
                  logger.debug "Updating Mailing with id #{mailing.id}"
                end
              end
              logger.debug "Batch importing #{new_mailings.length} mailings"
              Mailing.import new_mailings
            end
          end

          # add at least 1 mailing variation per email 
          mailings_without_variations = Mailing.joins("left join mailing_variations on mailings.id = mailing_variations.mailing_id").where("mailing_variations.id is null")
          mailings_without_variations.each do |m| 
            MailingVariation.create! mailing_id: m.id
          end

        end
      end
    end
  end
end
