require 'identity/importer/tasks/mailing_members'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class MailingMembers < Identity::Importer::Tasks::MailingMembers

          def self.sql mailing_id
            %{
              SELECT
                email.email as email,
                eventqueue.id as id
                FROM civicrm_mailing m JOIN civicrm_mailing_job job ON m.id = job.mailing_id
                JOIN civicrm_mailing_event_queue eventqueue ON eventqueue.job_id = job.id
                JOIN civicrm_email email ON eventqueue.email_id = email.id
                WHERE job.job_type = 'child'
                AND m.id = #{mailing_id}
                ORDER BY eventqueue.id ASC
            }
          end

        end
      end
    end
  end
end