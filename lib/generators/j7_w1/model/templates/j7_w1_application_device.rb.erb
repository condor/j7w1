class J7W1ApplicationDevice < ActiveRecord::Base
  set_table_name 'j7w1_application_devices'

  belongs_to :owner, polymorphic: true

<% if options['async_engine'] %>
  after_create :create_device_endpoint_async
  after_destroy :destroy_device_endpoint_async
<% else %>
  after_create :create_device_endpoint
  after_destroy :destroy_device_endpoint
<% end %>

  def push!(options = {})
    J7W1::PushClient.push device_endpoint_arn, platform, *options
  end

<% case options['async_engine'] %>
   <% when 'delayed_job' %>
   def create_device_endpoint_async
     delay.create_device_endpoint
   end

   def destroy_device_endpoint_async
     delay.destroy_device_endpoint
   end
   <% when 'sidekiq' %>
   def create_device_endpoint_async
     J7W1Worker.create_device_endpoint id
   end

   def destroy_device_endpoint_async
     J7W1Worker.destroy_device_endpoint id
   end
<% end %>
  def create_device_endpoint
    device_endpoint_arn = J7W1::PushClient.create_device_endpoint device_identifier, platform_id,
      custom_user_data: "#{owner.class} ##{owner.id}"
    update_attributes! device_endpoint_arn: device_endpoint_arn
  end

  def destroy_device_endpoint
    J7W1::PushClient.destroy_endpoint device_arn
  end
end
