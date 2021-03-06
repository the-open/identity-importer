require 'identity/importer/tasks/campaigns'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Campaigns < Identity::Importer::Tasks::Campaigns

          def self.sql
            last_campaign =  Campaign.where(campaign_type: nil).where.not(controlshift_campaign_id: nil).order("controlshift_campaign_id desc").first
            campaign_types = Identity::Importer.configuration.campaign_types
            if campaign_types.blank?
              raise ArgumentError, "Campaign Types is empty, please set campaign_types to a valid array"
            end

            campaign_types = Identity::Importer::Utils.format_array_for_sql campaign_types

            %{
              SELECT campaign.title as name,
                campaign.id as external_id,
                filar.campaign_type as type
              FROM civicrm_campaign campaign
                JOIN (SELECT v.value as campaign_type_id, v.label as campaign_type
                  FROM civicrm_option_group o join civicrm_option_value v on o.id = v.option_group_id
                  WHERE o.name ='campaign_type'
                  AND label in (#{campaign_types})) filar
                  ON campaign.campaign_type_id = filar.campaign_type_id
                  #{"WHERE campaign.id > #{last_campaign.controlshift_campaign_id}" unless last_campaign.nil?}
            }
          end

        end
      end
    end
  end
end
