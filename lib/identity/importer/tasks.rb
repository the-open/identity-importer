require 'identity/importer/tasks/civicrm/actions'
require 'identity/importer/tasks/civicrm/campaigns'
require 'identity/importer/tasks/civicrm/clicks'
require 'identity/importer/tasks/civicrm/mailings'
require 'identity/importer/tasks/civicrm/mailing_members'
require 'identity/importer/tasks/civicrm/members'
require 'identity/importer/tasks/civicrm/opens'

require 'identity/importer/tasks/actionkit/actions'
require 'identity/importer/tasks/actionkit/campaigns'
require 'identity/importer/tasks/actionkit/clicks'
require 'identity/importer/tasks/actionkit/mailings'
require 'identity/importer/tasks/actionkit/mailing_members'
require 'identity/importer/tasks/actionkit/members'
require 'identity/importer/tasks/actionkit/opens'

module Identity
  module Importer
    module Tasks

      def self.run
        Identity::Importer::Tasks::CiviCRM::Campaigns.run
        Identity::Importer::Tasks::CiviCRM::Members.run
        Identity::Importer::Tasks::CiviCRM::Mailings.run
        Identity::Importer::Tasks::CiviCRM::MailingMembers.run
        Identity::Importer::Tasks::CiviCRM::Opens.run
        Identity::Importer::Tasks::CiviCRM::Clicks.run
        Identity::Importer::Tasks::CiviCRM::Actions.run
      end

      def self.actionkit_run
        Identity::Importer::Tasks::ActionKit::Campaigns.run
        Identity::Importer::Tasks::ActionKit::Members.run
        Identity::Importer::Tasks::ActionKit::Mailings.run
        Identity::Importer::Tasks::ActionKit::MailingMembers.run
        Identity::Importer::Tasks::ActionKit::Opens.run
        Identity::Importer::Tasks::ActionKit::Clicks.run
        Identity::Importer::Tasks::ActionKit::Actions.run
      end


    end
  end
end
