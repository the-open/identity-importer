module Identity
  module Importer
    module Tasks
      class Members

        def self.run
          members = Identity::Importer.connection.run_query(sql)

          members.each do |member_data|
            data = {
              name: (member_data['firstname'] or '(none)')+' '+(member_data['lastname'] or '(none)'),
              email: member_data['email'],
              created_at: member_data['created_at'],
              updated_at: member_data['updated_at']
            }

            member = Member.find_or_initialize_by(email: member_data['email'])

            if member.new_record?
              member.attributes = data
              member.save!
            end
          end
        end

      end
    end
  end
end
