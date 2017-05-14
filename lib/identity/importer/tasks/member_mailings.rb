require 'activerecord-import'

module Identity
  module Importer
    class MailingIncomplete < StandardError
    end

    module Tasks
      class MemberMailings

        def self.run
          logger = Identity::Importer.logger
          unsynced_mailings = Mailing.where(recipients_synced: false)

          member_cache = Hash[Member.select(:email, :id).pluck(:email, :id)]

          logger.info "#{unsynced_mailings.count} mailings to sync, member cache size #{member_cache.size}"

          unsynced_mailings.each do |mailing|
            mailing_members = Identity::Importer.connection.run_query(sql(mailing.external_id))

            logger.info "Mailing #{mailing.id}. #{mailing.subject} recipients: #{mailing_members.count}"
            begin
              ActiveRecord::Base.transaction do
                mailing_members.each_slice(1000) do |mailing_members_slice| 
                  member_mailings = []
                  mailing_members_slice.each do |mailing_member|
                    member_id = member_cache[mailing_member['email']]
                    if member_id.nil?
                      next # we might not have all these members..because they opted out and got removed.
                      # raise MailingIncomplete, "The mailing #{mailing.id} doesn't have all recipients synced"
                    end
                    
                    member_mailing = MemberMailing.new
                    member_mailing.attributes = {
                      'mailing_id' => mailing.id,
                      'member_id' => member_id,
                      'external_id' => mailing_member['id']
                    }

                    member_mailings << member_mailing
                  end
                  logger.info "Batch import #{member_mailings.count} mm's"
                  MemberMailing.import member_mailings
                end

                mailing.recipients_synced = true
                mailing.save!
                logger.info "Mailing #{mailing.id}. #{mailing.subject} saved"
              end
            rescue MailingIncomplete => e
              logger.error "#{e.message}, skipping it"
            end
          end

        end

      end
    end
  end
end
