require 'identity/importer/tasks/members'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Members < Identity::Importer::Tasks::Members

          def self.sql(mailing)
            %{
              SELECT
                e.email as email,
                c.id as contact_id,
                c.first_name as firstname,
                c.last_name as lastname,
                addr.postal_code as postcode,
                c.created_date as created_at,
                c.modified_date as updated_at
                FROM civicrm_mailing m JOIN civicrm_mailing_job job ON m.id = job.mailing_id
                JOIN civicrm_mailing_event_queue q ON q.job_id = job.id
                JOIN civicrm_email e ON q.email_id = e.id
                JOIN civicrm_contact c ON q.contact_id = c.id
                LEFT JOIN civicrm_address addr ON c.id = addr.contact_id
                WHERE job.job_type = 'child'
                AND m.id = #{mailing.external_id}
                ORDER BY q.id ASC
            }
          end

        end
      end
    end
  end
end
