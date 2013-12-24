module J7W1
  class Configuration
    include J7W1::Util

    module MobileEndpoint
      def arn
        self[:arn]
      end
    end

    module IOSEndpoint
      def self.extended(obj)
        obj.__send__ :extend, MobileEndpoint
      end

      def sandbox?
        @sandbox
      end

      def confirm_sandbox
        @sandbox = (arn =~ /:app\/APNS_SANDBOX\//)
      end
    end

    module AndroidEndpoint
      def self.extended(obj)
        obj.__send__ :extend, MobileEndpoint
      end
    end 

    module Account
      [:access_key_id, :secret_access_key, :region].each do |attr|
        module_eval "def #{attr};self[:#{attr}];end"
      end
    end

    def initialize(configuration_values)
      @values = symbolize_keys_recursive(configuration_values)
      if ios_endpoint
        ios_endpoint.extend(IOSEndpoint)
        ios_endpoint.confirm_sandbox
      end
      if android_endpoint
        android_endpoint.extend(AndroidEndpoint)
      end
      account.extend(Account)
    end

    def account
      @values[:account]
    end

    def ios_endpoint
      return nil unless @values[:app_endpoint]
      @values[:app_endpoint][:ios]
    end

    def android_endpoint
      #TODO configの対応
      return nil unless @values[:app_endpoint]
      @values[:app_endpoint][:android]
    end
  end
end
