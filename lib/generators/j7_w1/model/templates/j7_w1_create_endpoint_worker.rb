class J7W1CreateEndpointWorker
  include Sidekiq::Worker

  def perform(id)
    J7W1ApplicationDevice.find(id).create_device_endpoint
  end
end
