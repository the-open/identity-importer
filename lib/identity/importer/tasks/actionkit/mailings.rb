module Identity
  module Importer
    module Tasks
      module ActionKit
        module Mailings

          COLUMNS_TO_SELECT = [
            'name',         # a staff-friendly name for this mailing
            'external_id',  # the id of the mailing object in your other system
            'subject',      # the subject line (or lines)
            'body_html',    #
            'body_plain',   #
            'from',         # the fromline
            'mailing_template_id', # the model mailing this was copied from
            'created_at',   # when the mailing object was created
            'sent_at',      # when you actually hit send on the mailing
            'member_count'  # the actual count (not expected) of mailings sent
          ]

          # Write SQL that returns as many of the above columns as applicable.

          SQL = %{
          SELECT
            min(s.text) as 'name',
            m.id as external_id,
            group_concat(distinct s.text) as subject,
            m.html as body_html,
            m.text as body_plain,
            if (m.custom_fromline, m.custom_fromline, f.from_line) as "from",
            m.created_at,
            m.queued_at as sent_at,
            count(um.user_id) as member_count
            FROM core_mailing m LEFT JOIN core_fromline f on (f.id=m.fromline_id)
            LEFT JOIN core_usermailing um on (m.id=um.mailing_id)
            LEFT JOIN core_mailingsubject s on (s.mailing_id=m.id)
            GROUP BY m.id;
          }

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
