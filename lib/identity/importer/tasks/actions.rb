require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Actions

        def self.run(sync_since=nil)
          logger = Identity::Importer.logger

          if sync_since.nil?
            last_action = MemberAction.order(:created_at).last
            sync_since = last_action.try(:created_at) || 0
          end
          logger.info "Sync Actions since #{sync_since}"

          actions = Identity::Importer.connection.run_query(sql(sync_since))
          logger.info "Queried for actions. got #{actions.count} rows, filling cache"
          
          got_members = Utils.member_cache
          logger.info "Cache filled."
          got_actions = {}
          
          actions_count = actions.count
          done_count = 0
          actions.each_slice(1000) do |action_events|
            logger.info "start slice"
            ActiveRecord::Base.transaction do
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
                  action.action_type =  Identity::Importer.configuration.action_types_map[action_data['type']]
                  action.campaign = campaign
                  action.name = campaign.name
                  action.save!
                end

                timestamp = action_data['created_at'].to_datetime
                member_action = MemberAction.new(action_id: action.id, created_at: timestamp, member_id: cached_member.id)

                new_member_actions << member_action
              end
              MemberAction.import new_member_actions
              logger.info "syncing actions #{done_count}/#{actions_count}, imported from batch: #{new_member_actions.length}/1000"

              ## XXX deduplicate
            end
          end

        end

      end
    end
  end
end
