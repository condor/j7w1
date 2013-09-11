require 'yaml'

module J7W1

  class << self
    attr_reader :current_strategy
    private :current_strategy

    def strategy(strategy_name, configuration: nil)
      mediator_layer = "j7w1/#{strategy_name}"
      require mediator_layer

      mediator_module = "::J7W1::#{strategy_name.camelcase}".constantize
      @current_strategy = mediator_module

      const_set(:PushClient, current_strategy::PushClient)
      ActiveRecord::Base.__send__ :include, current_strategy::ActiveRecord
      configure configuration
    end

    def configure(configuration)
      return unless configuration

      configuration = configuration_values_of(configuration)
      current_strategy.configure configuration
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
        when ActiveSupport::HashWithIndifferentAccess
          value
        when Hash
          value.symbolize_keys
        when Array
          value.map{|v|regularize_for_symbolization(v)}
        else
          value
      end
    end
  end
end
