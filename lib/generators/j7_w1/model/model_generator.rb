require 'rails/generators'

module J7W1
  class ModelGenerator < Rails::Generators::Base
    source_root File.join(File.dirname(__FILE__), 'templates')
    class_option :async_engine, type: :string, default: nil,
      desc: 'AWS register/deregister processing method'

    def create_model_file
      template "j7_w1_application_device.rb.erb",
        "app/models/j7_w1_application_device.rb"

      if options['async_engine'] == 'sidekiq'
        copy_file "j7_w1_create_endpoint_worker.rb",
          "app/workers/j7_w1_create_endpoint_worker.rb"
        copy_file "j7_w1_destroy_endpoint_worker.rb",
          "app/workers/j7_w1_destroy_endpoint_worker.rb"
      end

      invoke "j7_w1:migration"
    end
  end
end
