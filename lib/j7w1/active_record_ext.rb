module J7W1
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      private
      def application_device_owner
        include InstanceMethods

        has_many :application_devices, class_name: 'J7W1ApplicationDevice',
          as: :owner
      end
    end

    module InstanceMethods
      def add_device(device_identifier, platform)
        device =
          J7W1ApplicationDevice.identified(device_identifier).on_platform(J7W1::Util.normalize_platform(platform)).
          first_or_initialize
        device.device_endpoint_arn = nil
        device.owner = self
        device.save!
      end

      def remove_device(device_identifier, platform)
        devices.where(device_identifier: device_identifier, platform: platform).
          destroy_all
      end

      def push!(options = {})
        application_devices.each do |device|
          device.push! options
        end
      end
    end
  end
end
