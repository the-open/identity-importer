require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Actions

        def self.run
          actions = Identity::Importer.connection.run_query(sql)

          ActiveRecord::Base.transaction do
            new_actions = []
            new_member_actions = []

            actions.each do |action_data|
              action = Action.find_or_initialize_by(external_id: action_data['external_id'])
              timestamp = action_data['created_at'].to_datetime
              action.attributes = {
                action_type: action_data['type'],
                created_at: timestamp,
                updated_at: timestamp
              }

              campaign = Campaign.find_by(controlshift_campaign_id: action_data['campaign_id'])

              action.campaign = campaign
              new_actions << action

              member = Member.find_by(email: mailing_member['email'])
              member_id = member.try(:id) || 1

              member_action = MemberAction.find_or_initialize_by(action_id: action.id)
              member_action.attributes = {
                member_id: member_id,
                created_at: timestamp
              }
              new_member_actions << member_action
            end
            Action.import new_actions
            MemberAction.import new_member_actions
          end
        end

      end
    end
  end
end
