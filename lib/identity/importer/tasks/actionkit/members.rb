require 'identity/importer/tasks/members'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class Members < Identity::Importer::Tasks::Members

          def self.sql
            anonymize = Identity::Importer.configuration.anonymize
            %{
              SELECT
                #{anonymize ? "concat(sha1(u.email), '@action.kit')" : "u.email"} as email,
                u.id as contact_id,
                u.first_name as firstname,
                #{anonymize ? "left(sha1(u.last_name), 10)" : "u.last_name"} as lastname,
                u.postal as postcode,
                u.created_at as created_at,
                u.updated_at as updated_at
                FROM core_user u
                ORDER BY u.id ASC
            }
          end

        end
      end
    end
  end
end
