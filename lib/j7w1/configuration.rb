module J7W1
  module Sns
    module ConfigurationMethods
      def account
        self[:account]
      end

      def ios_endpoint
        self
      end
    end

    class Configuration
      module IOSEndpoint
        def sandbox?
          !!self['sandbox']
        end

        def arn
          self['arn']
        end
      end

      def initialize(configuration_values)
        configuration_values = configuration_values.symbolize_keys! unless
          configuration_values.is_a? ActiveSupport::HashWithIndifferentAccess
        @values = configuration_values
        ios_endpoint.extend IOSEndpoint
      end

      def account
        @values[:account]
      end

      def ios_endpoint
        @values[:app_endpoint][:ios]
      end

      def android_endpoint
        #TODO configの対応
        @values[:endpoint][:android]
      end
    end

    def self.configure(sns_configuration)
      @configuration = Configuration.new sns_configuration
    end

    def self.configuration
      @configuration
    end

    def self.create_sns(configuration = self.configuration)
      AWS::SNS.new configuration.account
    end
  end
end

require 'j7w1/sns/active_record'
require 'j7w1/sns/push_client'
