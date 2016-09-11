module Identity
  module Importer
    module Tasks
      class Members

        def self.run
          unsycned_mailings = Mailing.where(recipients_synced: false)

          unsycned_mailings.each do |mailing|
            members = Identity::Importer.connection.run_query(sql(mailing))

            ActiveRecord::Base.transaction do
              members.each do |member_data|
                data = {
                  name: (member_data['firstname'] or '(none)')+' '+(member_data['lastname'] or '(none)'),
                  email: member_data['email'],
                  contact: {postcode: member_data['postcode']}.to_json
                }

                member = Member.find_or_initialize_by member_data['email']
                if member.new_record?
                  member.attributes = data
                  member.save!
                end

                member_mailing = MemberMailing.new
                member_mailing.attributes = {
                  'mailing_id' => mailing.id,
                  'member_id' => member.id,
                  'external_id' => member_data['contact_id'],
                  'created_at' => member_data['created_at'],
                  'updated_at' => member_data['updated_at']
                }
              end
              mailing.recipients_synced = true
              mailing.save!
            end
          end
        end

      end
    end
  end
end
