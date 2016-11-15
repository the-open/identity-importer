require 'identity/importer/connection'
require 'identity/importer/configuration'
require 'identity/importer/tasks'
require 'identity/importer/version'
require 'identity/importer/utils'

require 'logger'

module Identity
  module Importer

    class << self
      attr_accessor :configuration
      attr_reader :connection
      attr_reader :logger
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def self.connection
      @connection ||= Connection.new
    end

    def self.logger
      if @logger.nil?
        @logger = Logger.new("#{Padrino.root}/log/identity_importer.log", 10, 100000000)
        @logger.level = Logger::DEBUG
      end
      @logger
    end

  end
end
