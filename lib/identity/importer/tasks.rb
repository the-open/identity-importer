require 'identity/importer/tasks/civicrm/mailings'
require 'identity/importer/tasks/civicrm/members'
require 'identity/importer/tasks/civicrm/mailing_members'

require 'identity/importer/tasks/actionkit/mailings'
require 'identity/importer/tasks/actionkit/members'
require 'identity/importer/tasks/actionkit/mailing_members'

module Identity
  module Importer
    module Tasks

      def self.run
        Identity::Importer::Tasks::CiviCRM::Mailings.run
      end

    end
  end
end
