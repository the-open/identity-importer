require 'identity/importer/tasks/optout'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Optout < Identity::Importer::Tasks::Optout

          def self.sql(since=nil)
            time_constraint = ''
            if since
              time_constraint = "AND act.activity_date_time >= " + Identity::Importer.connection.quote(since)
            end

            %{
              SELECT
                      email.email as email,
                      act.activity_date_time as created_at
                       FROM civicrm_activity act
                       JOIN (
                           SELECT v.value as id, v.name
                           FROM civicrm_option_group o
                           JOIN civicrm_option_value v ON o.id = v.option_group_id
                           WHERE o.name = 'activity_type' and v.name = 'optout'
                       ) optout_type
                       ON act.activity_type_id = optout_type.id
                       JOIN civicrm_activity_contact act_con
                       ON act.id = act_con.activity_id
                       JOIN civicrm_email email
                       ON email.contact_id = act_con.contact_id
                       WHERE act.status_id = 2 #{time_constraint}
            }
          end

        end
      end
    end
  end
end
