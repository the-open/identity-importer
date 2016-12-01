require 'identity/importer/tasks/members'

module Identity
  module Importer
    module Tasks
      module CiviCRM
        class Members < Identity::Importer::Tasks::Members

          def self.sql
            last_member = Member.where(crypted_password: nil).order("created_at desc").first
            %{
              SELECT
                contact.id as contact_id,
                email.email as email,
                contact.first_name as firstname,
                contact.last_name as lastname,
                addr.postal_code as postcode,
                contact.created_date as created_at,
                contact.modified_date as updated_at
                FROM civicrm_email email JOIN civicrm_contact contact ON email.contact_id = contact.id
                LEFT JOIN civicrm_address addr ON contact.id = addr.contact_id
                #{"WHERE contact.created_date > \"#{last_member.created_at.getlocal.strftime('%Y-%m-%d %H:%M:%S')}\"" unless last_member.nil?}
            }
          end

        end
      end
    end
  end
end
