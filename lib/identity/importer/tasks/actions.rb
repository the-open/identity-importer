require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Actions

        def self.run
          last_action = Action.order(:created_at).last
          actions = Identity::Importer.connection.run_query(sql(last_action.try(:created_at) || 0))
          logger = Identity::Importer.logger

          got_members = Utils.member_cache
          
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
                elsif action.changed?
                  action.save!
                end

                member_action = MemberAction.find_or_initialize_by(action_id: action.id, created_at: timestamp, memnber_id: cached_member.id)

                if member_action.new_record?
                  new_member_actions << member_action
                  logger.debug "Importing MemberAction with id #{member_action.id}"
                end
              end
              Action.import new_actions
              MemberAction.import new_member_actions
              logger.info "syncing actions #{done_count}/#{actions_count}"
            end
          end

        end

      end
    end
  end
end
