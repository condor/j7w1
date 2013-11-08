module J7W1
  module ActiveRecordExt
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      private
      def application_device_owner
        include InstanceMethods

        has_many :application_devices, class_name: 'J7W1ApplicationDevice'
      end
    end

    module InstanceMethods
      def add_device(device_identifier, platform)
        device =
          J7W1ApplicationDevice.identified(device_identifier).on_platform(J7W1::Util.normalize_platform(platform)).
          first_or_initialize
        device.endpoint_arn = nil
        device.owner = self
        device.save!
      end

      def remove_device(device_identifier, platform)
        devices.where(device_identifier: device_identifier, platform: platform).
          destroy_all
      end

      def push!(options = {})
        sns_client = self.create_sns_client
        aplication_devices.each do |device|
          device.push! options.tap{|o|o.merge! sns_client: sns_client}
        end
      end
    end
  end
end
