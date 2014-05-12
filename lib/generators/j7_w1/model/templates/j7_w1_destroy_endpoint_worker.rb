class J7W1DestroyEndpointWorker
  include Sidekiq::Worker

  def perform(endpoint_arn)
    J7W1ApplicationDevice.destroy_device_endpoint endpoint_arn
  end
end
