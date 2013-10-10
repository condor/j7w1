module J7W1::Sns
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      private
      def push_recipient
        include InstanceMethods

        has_one :sns_endpoint, as: :recipient
      end
    end

    module InstanceMethods
      def device_token_updated
        if device_token
          update_sns_endpoint
        else
          remove_sns_endpoint
        end
      end

      def remove_sns_endpoint
        sns_endpoint.destroy if sns_endpoint
      end

      def update_sns_endpoint
        return if sns_endpoint && sns_endpoint.device_token == device_token

        self.sns_endpoint ||= build_sns_endpoint
        sns_endpoint.device_token = device_token
        sns_endpoint.save!
      end
    end
  end
end
