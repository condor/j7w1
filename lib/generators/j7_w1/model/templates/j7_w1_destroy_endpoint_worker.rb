class J7W1DestroyEndpointWorker
  include Sidekiq::Worker

  def perform(id)
    J7W1ApplicationDevice.find(id).destroy_device_endpoint
  end
end
