require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Actions

        def self.run
          last_action = MemberAction.order(:created_at).last
          actions = Identity::Importer.connection.run_query(sql(last_action.try(:created_at) || 0))
          logger = Identity::Importer.logger

          got_members = Utils.member_cache
          got_actions = {}
          
          actions_count = actions.count
          done_count = 0
          actions.each_slice(1000) do |action_events|
            ActiveRecord::Base.transaction do
              new_actions = []
              new_member_actions = []

              action_events.each do |action_data|
                done_count += 1

                cached_member = got_members[action_data['email']]
                next if cached_member.nil?

                action_ex_id = action_data['external_id']
                action = got_actions[action_ex_id]
                if action.nil?
                  action = Action.find_or_initialize_by(external_id: action_data['external_id'])
                  got_actions[action_ex_id] = action
                end
                if action.new_record?
                  campaign = Campaign.find_by(controlshift_campaign_id: action_data['campaign_id'])
                  action.action_type =  Identity::Importer.configuration.action_types_map[saction_data['type']]
                  action.campaign = campaign
                  action.save!
                end

                timestamp = action_data['created_at'].to_datetime
                member_action = MemberAction.new(action_id: action.id, created_at: timestamp, member_id: cached_member.id)

                new_member_actions << member_action
              end
              MemberAction.import new_member_actions
              logger.info "syncing actions #{done_count}/#{actions_count}"
            end
          end

        end

      end
    end
  end
end
