module J7W1
  module PushClient

    class << self
      def push_histories
        @push_histories ||= []
      end

      def push(endpoint_arn, platform, options)
        @push_histories.push(options.merge(device: {platform: platform, endpoint_arn: endpoint_arn}))
      end
    end
  end
end
