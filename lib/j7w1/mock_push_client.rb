module J7W1
  module MockPushClient

    class << self
      def push_histories
        @push_histories ||= []
      end

      def push(endpoint_arn, platform, options)
        push_histories.push(options.merge(device: {platform: platform, endpoint_arn: endpoint_arn}))
      end

      def create_device_endpoint(device_identifier, platform, options = {})
        [device_identifier, J7W1::Util.normalize_platform(platform)].compact.join('@')
      end
    end
  end
end
