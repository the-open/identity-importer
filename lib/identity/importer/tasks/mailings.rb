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
          'member_count'  # the actual count (not expected) of mailings sent
        ]

        def self.run
          mailings = []
          Identity::Importer.connection.run_query(sql).each do |mailing_data|
            mailing = Mailing.find_or_initialize_by(external_id: mailing_data['external_id'])
            if mailing.new_record?
              mailing.attributes = mailing_data.select do |column_name, value|
                COLUMNS_TO_SELECT.include? column_name
              end
            end

            campaign = Campaign.find_by(controlshift_campaign_id: action_data['campaign_id'])

            mailing.campaign_id = campaign.try(:id)
            mailing.recipients_synced = false
            mailings << mailing
          end
          Mailing.import mailings
        end

      end
    end
  end
end
