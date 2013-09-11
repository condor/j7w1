require 'yaml'

module J7W1

  class << self
    attr_reader :current_strategy
    private :current_strategy

    def strategy(strategy_name, configuration: nil)
      mediator_layer = "j7w1/#{strategy_name}"
      require mediator_layer

      strategy_as_module_name = strategy_name.to_s.gsub(/^[a-z]/){|c|c.upcase}.gsub(/_([a-z])/){|_|$1.upcase}
      mediator_module_name = "::J7W1::#{strategy_as_module_name}"
      mediator_module = const_get(mediator_module_name.to_sym)

      @current_strategy = {
          filename: mediator_layer,
          module: mediator_module,
      }

      const_set(:PushClient, mediator_module::PushClient)
      const_set(:ActiveRecordExt, mediator_module::ActiveRecordExt)
      ActiveRecord::Base.send :include, ActiveRecordExt
      configure configuration
    end

    def configure(configuration)
      return unless configuration

      configuration = configuration_values_of(configuration)
      enable_active_record if configuration[:active_record]
      current_strategy.configure configuration
    end

    def enable_active_record
      require "#{current_strategy[:filename]}/active_record"

      active_record_extension = current_strategy[:module_name].const_get(:ActiveRecord)
      ActiveSupport.on_load do
        ActiveRecord::Base.__send__ :include, active_record_extension
      end
    end

    private
    def configuration_values_of(configuration)
      case configuration
        when String
          configuration_values_of(YAML.load(File.read(configuration)))
        when Hash
          symbolize_keys_recursive(configuration)
      end
    end

    def symbolize_keys_recursive(hash)
      hash.inject({}) do |h, kv|
        (key, value) = kv
        h[key.to_sym] = regularize_for_symbolization(value)
        h
      end
    end

    def regularize_for_symbolization(value)
      case value
        when Hash
          symbolize_keys_recursive(value)
        when Array
          value.map{|v|regularize_for_symbolization(value)}
        else
          value
      end
    end
  end
end
