require 'yaml'

module J7W1

  class << self
    attr_reader :current_strategy
    private :current_strategy

    def configure(configuration)
      raise ArgumentError,
        "J7W1 configuration values should be an instance of Hash or String, but actually it is a kind of #{configuration.class.name}" unless
      configuration.is_a?(Hash) || configuration.is_a?(String)

      configuration = configuration_values_of(configuration)
      if configuration[:mock]
        require 'j7w1/mock'
        return
      end

      require 'j7w1/concrete'
      @configuration = Configuration.new configuration
    end

    def configuration
      @configuration
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

if const_defined?(:ActiveSupport) && Hash.instance_methods.include?(:symbolize_keys) &&
  const_get((:ActiveSupport).const_defined?(:HashWithIndifferentAccess)
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
else
    def regularize_for_symbolization(value)
      case value
        when Hash
          value.inject({}) do |h, kv|
            (key, value) = kv
            h[key.to_sym] = regularize_for_symbolization(value)
            h
          end
        when Array
          value.map{|v|regularize_for_symbolization(v)}
        else
          value
      end
    end
end
  end
end
