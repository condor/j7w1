module J7W1
  class Configuration
    module IOSEndpoint
      def sandbox?
        !!self['sandbox']
      end

      def arn
        self['arn']
      end
    end

    module AndroidEndpoint
      def arn
        self['arn']
      end
    end 

    def initialize(configuration_values)
      @values = configuration_values
      ios_endpoint.try :extend, IOSEndpoint
      android_endpoint.try :extend, AndroidEndpoint
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
end
