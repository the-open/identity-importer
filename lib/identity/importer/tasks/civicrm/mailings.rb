require 'identity/importer/tasks/mailings'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Mailings < Identity::Importer::Tasks::Mailings

          def self.sql
            %{
              SELECT m.name,
                m.id as external_id,
                m.subject,
                m.body_html,
                m.body_text as body_plain,
                m.from_name || ' <' || m.from_email || '>' as "from",
                m.created_date as created_at,
                count(q.id) as member_count
                FROM civicrm_mailing m LEFT JOIN civicrm_mailing_job job ON m.id = job.mailing_id
                LEFT JOIN  civicrm_mailing_event_queue q ON q.job_id = job.id
                WHERE job.job_type = 'child'
                GROUP BY m.id;
            }
          end

        end
      end
    end
  end
end
