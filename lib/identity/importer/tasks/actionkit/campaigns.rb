require 'identity/importer/tasks/campaigns'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class Campaigns < Identity::Importer::Tasks::Campaigns

          def self.sql
            # campaign_types = Identity::Importer.configuration.campaign_types
            # if campaign_types.blank?
            #   raise ArgumentError, "Campaign Types is empty, please set campaign_types to a valid array"
            # end

            # campaign_types = campaign_types.map do |campaign_type|
            #   "'#{campaign_type}'"
            # end.join(",")

            # %{
            #   SELECT campaign.title as name,
            #     filar.campaign_type as campaign_type,
            #     FROM civicrm_campaign campaign
            #     JOIN (SELECT v.value as campaign_type_id, v.label as campaign_type
            #       FROM civicrm_option_group o join civicrm_option_value v on o.id = v.option_group_id
            #       WHERE o.name ='campaign_type' and label in (#{campaign_types})) filar
            #       ON campaign.campaign_type_id = filar.campaign_type_id
            # }
          end

        end
      end
    end
  end
end
