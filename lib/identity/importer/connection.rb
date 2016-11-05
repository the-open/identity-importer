require 'mysql2'

module Identity
  module Importer
    class Connection

      def initialize
        @configuration = Identity::Importer.configuration

        if @configuration.valid_database_config?
          case @configuration.database_adapter.downcase
          when "mysql"
            puts "Trying to connect to a MySQL DB"
            @client = Mysql2::Client.new(
              database: @configuration.database_name,
              host: @configuration.database_host,
              username: @configuration.database_user,
              password: @configuration.database_password,
              port: @configuration.database_port
            )
            puts "Connected to MySQL database"
          else
            raise ArgumentError, "Unsupported database adapter"
          end
        else
          raise ArgumentError, "Database configuration is not valid"
        end

      end

      def run_query query
        @client.query(query)
      end

    end
  end
end
