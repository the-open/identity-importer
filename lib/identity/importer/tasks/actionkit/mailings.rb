require 'identity/importer/tasks/mailings'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class Mailings < Identity::Importer::Tasks::Mailings

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

        end
      end
    end
  end
end
