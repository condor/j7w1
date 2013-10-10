module J7W1
  class ApplicationDevice < ActiveRecord::Base
    set_table_name 'j7w1_application_devices'

    belongs_to :owner, polymorphic: true

    after_create :create_device_endpoint
    after_destroy :destroy_device_endpoint

    def push!(options = {})
      J7W1::PushClient.push device_endpoint_arn, platform, *options
    end

    private
    def create_device_endpoint
      device_endpoint_arn = J7W1::PushClient.create_device_endpoint device_identifier, platform_id,
        custom_user_data: "#{owner.class} ##{owner.id}"
      update_attributes! device_endpoint_arn: device_endpoint_arn
    end

    def destroy_device_endpoint
      J7W1::PushClient.destroy_endpoint device_arn
    end
  end
end
