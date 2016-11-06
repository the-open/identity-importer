require 'identity/importer/connection'
require 'identity/importer/configuration'
require 'identity/importer/tasks'
require 'identity/importer/version'
require 'identity/importer/utils'

module Identity
  module Importer

    class << self
      attr_accessor :configuration
      attr_reader :connection
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

  end
end
