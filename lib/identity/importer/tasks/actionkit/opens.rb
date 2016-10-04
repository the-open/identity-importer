require 'identity/importer/tasks/opens'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class Opens < Identity::Importer::Tasks::Opens

          def self.sql mailing_id
            %{
              SELECT
                u.email as email,
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
