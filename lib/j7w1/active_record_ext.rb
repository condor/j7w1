module J7W1
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      private
      def terminal_owner
        include InstanceMethods

        has_many :application_devices, class_name: 'J7W1::ApplicationDevice'
      end
    end

    module InstanceMethods
      def add_device(device_identifier, platform)
        device =
          devices.where(device_identifier: device_identifier, platform: platform).
          find_or_initialize
        device.endpoint_arn = nil
        device.save!
      end

      def remove_device(device_identifier, platform)
        devices.where(device_identifier: device_identifier, platform: platform).
          destroy_all
      end

      def push!(options = {})
        sns_client = self.create_sns_client
        aplication_devices.each do |device|
          device.push! sns_client, *options
        end
      end
    end
  end
end
