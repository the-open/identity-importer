require 'identity/importer/tasks/members'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Members < Identity::Importer::Tasks::Members

          def self.sql(sync_since=nil)
            if sync_since
              where_when = "AND contact.created_date > " + Identity::Importer.connection.quote(sync_since)
            else
              where_when = ''
            end
            

            anonymize = Identity::Importer.configuration.anonymize
            %{
              SELECT
                contact.id as contact_id,
                #{anonymize ? "concat(sha1(email.email), '@civi.crm')" : "email.email"} as email,
                contact.first_name as firstname,
                #{anonymize ? "left(sha1(contact.last_name), 10)" : "contact.last_name"} as lastname,
                addr.postal_code as postcode,
                contact.created_date as created_at,
                contact.modified_date as updated_at
                FROM civicrm_email email JOIN civicrm_contact contact ON email.contact_id = contact.id
                LEFT JOIN civicrm_address addr ON contact.id = addr.contact_id
                WHERE is_deleted = 0 AND is_opt_out = 0
                #{where_when}
                ORDER BY contact.created_date ASC
            }

            # XXX maybe add optout from email model (check column)
          end

        end
      end
    end
  end
end
