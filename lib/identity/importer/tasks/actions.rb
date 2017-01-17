require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Actions

        def self.run
          actions = Identity::Importer.connection.run_query(sql)
          logger = Identity::Importer.logger

          actions.each_slice(1000) do |action_events|
            ActiveRecord::Base.transaction do
              new_actions = []
              new_member_actions = []

              action_events.each do |action_data|
                action = Action.find_or_initialize_by(external_id: action_data['external_id'])
                timestamp = action_data['created_at'].to_datetime
                action.attributes = {
                  action_type: action_data['type'],
                  created_at: timestamp,
                  updated_at: timestamp
                }

                campaign = Campaign.find_by(controlshift_campaign_id: action_data['campaign_id'])

                action.campaign = campaign

                if action.new_record?
                  new_actions << action
                  logger.debug "Importing Action with id #{action.id}"
                elsif action.changed?
                  action.save!
                  logger.debug "Updating Action with id #{action.id}"
                end

                member = Member.find_by(email: mailing_member['email'])
                member_id = member.try(:id) || 1

                member_action = MemberAction.find_or_initialize_by(action_id: action.id)
                member_action.attributes = {
                  member_id: member_id,
                  created_at: timestamp
                }

                if member_action.new_record?
                  new_member_actions << member_action
                  logger.debug "Importing MemberAction with id #{member_action.id}"
                elsif member_action.changed?
                  member_action.save!
                  logger.debug "Updating MemberAction with id #{member_action.id}"
                end
              end
              Action.import new_actions
              MemberAction.import new_member_actions
            end
          end
        end

      end
    end
  end
end
