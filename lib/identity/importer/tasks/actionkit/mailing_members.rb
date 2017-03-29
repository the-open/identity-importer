require 'identity/importer/tasks/member_mailings'

module Identity
  module Importer
    module Tasks
      module ActionKit
        class MemberMailings < Identity::Importer::Tasks::MemberMailings

          def self.sql mailing_id
            anonymize = Identity::Importer.configuration.anonymize
            %{
              SELECT
                #{anonymize ? "concat(sha1(u.email), '@action.kit')" : "u.email"} as email,
                m.created_at as timestamp
              FROM core_usermailing m
              JOIN core_user u on (u.id = m.user_id)
              WHERE m.mailing_id = #{mailing_id}
              ORDER BY 2 ASC
            }
          end

        end
      end
    end
  end
end
