require 'identity/importer/tasks/actions'
require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Actions < Identity::Importer::Tasks::Actions

          def self.sql(last_action=nil)
            anonymize = Identity::Importer.configuration.anonymize

            action_types = Identity::Importer.configuration.action_types
            if action_types.blank?
              raise ArgumentError, "Action Types is empty, please set action_types to a valid array"
            end

            action_types = Identity::Importer::Utils.format_array_for_sql action_types

            campaigns = Campaign.where.not(controlshift_campaign_id: nil).pluck(:controlshift_campaign_id)
            %{
               SELECT
                #{anonymize ? "concat(sha1(email.email), '@civi.crm')" : "email.email"} as email,
                 act_type.activity_name as type,
                 act.activity_date_time as created_at,
                 act.id as external_id,
                 camp.id as campaign_id
               FROM civicrm_campaign camp
                 JOIN civicrm_activity act ON camp.id = act.campaign_id
                 JOIN (SELECT v.value as activity_type_id, v.label as activity_name
                      FROM civicrm_option_group o join civicrm_option_value v ON o.id = v.option_group_id
                      WHERE o.name ='activity_type' AND label IN (#{action_types})) as act_type
                      ON act.activity_type_id = act_type.activity_type_id
                  JOIN civicrm_activity_contact act_con ON act.id = act_con.activity_id
                  JOIN civicrm_email email ON email.contact_id = act_con.contact_id
               WHERE camp.id IN (#{campaigns.join(",")})
                     AND act.activity_date_time > #{ActiveRecord::Base.connection.quote(last_action)}
               ORDER BY act.activity_date_time ASC;
            }
          end

        end
      end
    end
  end
end
