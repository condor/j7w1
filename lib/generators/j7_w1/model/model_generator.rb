require 'rails/generators'

module J7W1
  class ModelGenerator < Rails::Generators::Base
    source_root File.join(File.dirname(__FILE__), 'templates')

    def create_model_file
      create_file "app/models/j7_w1_application_device.rb"
    end
  end
end
