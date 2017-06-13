module Identity
  module Importer
    module Utils

      def self.format_array_for_sql array
        array.map do |value|
          "'#{value}'"
        end.join(",")
      end

      def self.member_cache
        MemberCache = Struct.new(:id, :email_subscription_id, :unsubscribed_at)

        Hash[Member.
              joins("LEFT JOIN member_subscriptions ms ON ms.member_id = members.id AND ms.subscription_id = #{Subscription::EMAIL_SUBSCRIPTION}").
              select("members.*, ms.id as email_subscription_id, ms.unsubscribed_at as unsubscribed_at").
              map { |m| [m.email, MemberCache.new(m.id, m.email_subscription_id, m.unsubscribed_at)]}]
      end

      def self.member_mailing_cache(mailing_id)
        Member.
          joins(:member_mailings).
          select('members.id, members.email, member_mailings.id as member_mailing_id').
          where(member_mailings: {mailing_id: mailing_id}).
          inject({}) do |cache, member|
          cache[member.email] = member.member_mailing_id
          cache
        end

      end

    end
  end
end
