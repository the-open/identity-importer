require 'identity/importer/tasks/clicks'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class Clicks < Identity::Importer::Tasks::Clicks

          def self.sql mailing_id
            anonymize = Identity::Importer.configuration.anonymize
            %{
              SELECT
                #{anonymize ? "concat(sha1(u.email), '@action.kit')" : "u.email"} as email,
                u.email as email,
                c.created_at as timestamp
              FROM core_click c
              JOIN core_user u on (u.id = c.user_id)
              WHERE c.mailing_id = #{mailing_id}
              ORDER BY 2 ASC
            }
          end

        end
      end
    end
  end
end
