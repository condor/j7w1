module J7W1
  module PushClient

    class << self
      def push_histories
        @push_histories ||= []
      end

      def push(device, options)
        @push_histories.push(options.merge(device: device))
      end
    end
  end

  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def device_owner_classes
        require 'set'
        @device_owner_classes ||= Set.new
      end

      private
      def device_owner
        device_owner_classes << self
      end
    end

    module InstanceMethods
      def push!(options = {})
        aplication_devices.each do |device|
          J7W1::PushClient.push device, options
        end
      end

      def add_device(device_identifier, platform)
      end

      def remove_device(device_identifier, platform)
      end
    end
  end
end
