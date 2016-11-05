require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Campaigns

        def self.run
          campaigns = Identity::Importer.connection.run_query(sql)

          ActiveRecord::Base.transaction do
            new_campaigns = []

            campaigns.each do |campaign_data|
              campaign = Campaign.find_or_initialize_by(name: campaign_data['name'])
              campaign.attributes = {
                controlshift_campaign_id: campaign_data['external_id'],
                campaign_type: campaign_data['type']
              }

              new_campaigns << campaign
            end

            Campaign.import new_campaigns
          end
        end

      end
    end
  end
end
