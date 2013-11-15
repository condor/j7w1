module J7W1
  class Configuration
    module IOSEndpoint
      def sandbox?
        @sandbox
      end

      def arn
        self[:arn]
      end

      def confirm_sandbox
        @sandbox = (arn =~ /:app\/APNS_SANDBOX\//)
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
      if ios_endpoint
        ios_endpoint.extend(IOSEndpoint)
        ios_endpoint.confirm_sandbox
      end
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
