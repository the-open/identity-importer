module Identity
  module Importer
    class Configuration
      attr_accessor :database_adapter
      attr_accessor :database_host
      attr_accessor :database_name
      attr_accessor :database_password
      attr_accessor :database_port
      attr_accessor :database_user
      attr_accessor :campaign_types
      attr_accessor :action_types
      attr_accessor :action_types_map
      attr_accessor :anonymize
      attr_accessor :add_email_subscription
      attr_accessor :log_to_stdout

      def initialize
        @database_adapter = ""
        @database_host = ""
        @database_name = ""
        @database_password = ""
        @database_port = "3306"
        @database_user = ""
        @campaign_types = []
        @action_types = []
        @action_types = {}
        @anonymize = false
        @add_email_subscription = false
        @log_to_stdout = false
      end

      def valid_database_config?
        !(@database_adapter.empty? || @database_host.empty? || @database_name.empty? || @database_password.empty? || @database_user.empty?)
      end

    end
  end
end
