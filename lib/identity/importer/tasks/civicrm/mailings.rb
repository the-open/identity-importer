require 'identity/importer/tasks/mailings'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Mailings < Identity::Importer::Tasks::Mailings

          def self.sql
            last_mailing = Mailing.where.not(external_id: nil).order("external_id desc").first

            %{
              SELECT mailing.name,
                mailing.id as external_id,
                mailing.subject,
                mailing.body_html,
                mailing.body_text as body_plain,
                mailing.from_name || ' <' || mailing.from_email || '>' as "from",
                mailing.created_date as created_at,
                mailing.campaign_id as campaign_id,
                mailing.created_date as created_at,
                mailing.scheduled_date as sent_at,
                job.scheduled_date as scheduled_for,
                job.end_date as finished_sending_at,
                job.end_date - job.start_date as send_time,
                count(q.id) as member_count
                FROM civicrm_mailing mailing LEFT JOIN civicrm_mailing_job job ON mailing.id = job.mailing_id
                LEFT JOIN  civicrm_mailing_event_queue q ON q.job_id = job.id
                WHERE job.job_type = 'child'
                #{"AND mailing.id > #{last_mailing.external_id}" unless last_mailing.nil?}
                GROUP BY mailing.id
            }
          end

        end
      end
    end
  end
end
