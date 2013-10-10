module J7W1
  module Stub
    module PushClient

      class << self
        def push_histories
          @push_histories ||= []
        end

        def push(destination, message: nil, badge: nil, sound: nil, sns: nil)
          @push_histories.push(
              {
              destination: destination,
              message: message,
              badge: badge,
              sound: sound,
              }
          )
        end
      end
    end

    module ActiveRecordExt
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def push_recipient_classes
          require 'set'
          @push_recipient_classes ||= Set.new
        end

        private
        def push_recipient
          push_recipient_classes << self
        end
      end

      module InstanceMethods
        def device_token_update_histories
          @device_token_update_histories ||= []
        end

        def device_token_updated
          @device_token_update_histories << {device_token: device_token}
        end
      end
    end
  end
end