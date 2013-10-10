require 'rails/generators'

module J7W1
  class ModelGenerator < Rails::Generators::Base
    source_root File.join(File.dirname(__FILE__), 'templates')
    class_option :async_engine, type: :string, default: nil,
      desc: 'AWS register/deregister processing method'

    def create_model_file
      #create_file "app/models/j7_w1_application_device.rb"
      #begin
      #  invoke "j7_w1:migration"
      #rescue
      #end
    end
  end
end
