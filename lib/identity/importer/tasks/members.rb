require 'activerecord-import'

module Identity
  module Importer
    module Tasks
      class Members

        def self.run
          members = Identity::Importer.connection.run_query(sql)

          ActiveRecord::Base.transaction do
            new_members = []
            members.each do |member_data|
              data = {
                name: (member_data['firstname'] or '(none)')+' '+(member_data['lastname'] or '(none)'),
                email: member_data['email'],
                created_at: member_data['created_at'],
                updated_at: member_data['updated_at']
              }

              member = Member.find_or_initialize_by(email: member_data['email'])
              member.attributes = data

              if member.new_record?
                new_members << member
              elsif member.changed?
                member.save!
              end
            end
            Member.import new_members
          end

        end

      end
    end
  end
end
