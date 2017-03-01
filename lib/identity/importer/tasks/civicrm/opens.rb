require 'identity/importer/tasks/opens'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Opens < Identity::Importer::Tasks::Opens

          def self.sql(mailing_id, last_open)
            anonymize = Identity::Importer.configuration.anonymize
            %{
              SELECT
                #{anonymize ? "concat(sha1(email.email), '@civi.crm')" : "email.email"} as email,
                open.time_stamp as timestamp
                FROM civicrm_mailing m JOIN civicrm_mailing_job job ON m.id = job.mailing_id
                JOIN civicrm_mailing_event_queue eventqueue ON eventqueue.job_id = job.id
                JOIN civicrm_email email ON eventqueue.email_id = email.id
                LEFT JOIN civicrm_mailing_event_opened open ON open.event_queue_id = eventqueue.id
                WHERE job.job_type = 'child'
                AND m.id = #{mailing_id}
                AND open.time_stamp is not null
                AND open.time_stamp > #{ActiveRecord::Base.connection.quote(last_open)}
                ORDER BY eventqueue.id ASC
            }
          end

        end
      end
    end
  end
end
