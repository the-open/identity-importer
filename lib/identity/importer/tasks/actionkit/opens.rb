require 'identity/importer/tasks/opens'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class Opens < Identity::Importer::Tasks::Opens

          def self.sql mailing_id
            anonymize = Identity::Importer.configuration.anonymize
            %{
              SELECT
                #{anonymize ? "concat(sha1(u.email), '@action.kit')" : "u.email"} as email,
                o.created_at as timestamp
              FROM core_open o
              JOIN core_user u on (u.id = o.user_id)
              WHERE o.mailing_id = #{mailing_id}
              ORDER BY 2 ASC
            }
          end

        end
      end
    end
  end
end
