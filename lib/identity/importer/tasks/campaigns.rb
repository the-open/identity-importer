require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Campaigns

        def self.run
          campaigns = Identity::Importer.connection.run_query(sql)
          logger = Identity::Importer.logger

          ActiveRecord::Base.transaction do
            new_campaigns = []

            campaigns.each do |campaign_data|
              campaign = Campaign.find_or_initialize_by(name: campaign_data['name'])
              campaign.attributes = {
                controlshift_campaign_id: campaign_data['external_id'],
                campaign_type: campaign_data['type']
              }

              if campaign.new_record?
                new_campaigns << campaign
                logger.debug "Importing Campaign with id #{campaign.id}"
              elsif campaign.changed?
                campaign.save!
                logger.debug "Saving Campaign with id #{campaign.id}"
              end
            end

            Campaign.import new_campaigns
          end
        end

      end
    end
  end
end
