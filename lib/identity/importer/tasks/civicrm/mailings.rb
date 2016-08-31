module Identity
  module Importer
    module Tasks
      module CiviCRM
        module Mailings

          SQL = %{
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

          COLUMNS_TO_SELECT = ['name', 'external_id', 'subject', 'body_html', 'body_plain', 'from', 'created_at', 'member_count']

          def self.run
            Identity::Importer.connection.run_query(SQL).each do |row|
              mailing = Mailing.find_or_initialize_by(external_id: row['external_id'])
              if mailing.new_record?
                mailing.attributes = row.select do |column_name, value|
                  COLUMNS_TO_SELECT.include? column_name
                end
              end

              mailing.recipients_synced = false
              mailing.save!
            end
          end

        end
      end
    end
  end
end
