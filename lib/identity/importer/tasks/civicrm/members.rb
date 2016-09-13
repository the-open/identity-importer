require 'identity/importer/tasks/members'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Members < Identity::Importer::Tasks::Members

          def self.sql(members)
            %{
              SELECT
                e.email as email,
                c.id as contact_id,
                c.first_name as firstname,
                c.last_name as lastname,
                addr.postal_code as postcode,
                c.created_date as created_at,
                c.modified_date as updated_at
                FROM civicrm_email e JOIN
                JOIN civicrm_contact c ON e.contact_id = c.id
                LEFT JOIN civicrm_address addr ON c.id = addr.contact_id
                ORDER BY c.id ASC
            }
          end

        end
      end
    end
  end
end
