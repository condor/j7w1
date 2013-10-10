module J7W1
  class Configuration
    module IOSEndpoint
      def sandbox?
        !!self[:sandbox]
      end

      def arn
        self[:arn]
      end
    end

    module AndroidEndpoint
      def arn
        self[:arn]
      end
    end 

    module Account
      [:access_key_id, :secret_access_key, :region].each do |attr|
        define_method(attr){self[attr]}
      end
    end

    def initialize(configuration_values)
      @values = configuration_values
      ios_endpoint.extend(IOSEndpoint) if ios_endpoint
      android_endpoint.extend(AndroidEndpoint) if android_endpoint
      account.extend(Account)
    end

    def account
      @values[:account]
    end

    def ios_endpoint
      @values[:app_endpoint][:ios]
    end

    def android_endpoint
      #TODO configの対応
      @values[:app_endpoint][:android]
    end
  end
end
