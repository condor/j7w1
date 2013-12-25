module J7W1
  module Util
    def normalize_platform(platform)
      platform = platform.to_s.downcase.to_sym unless platform.is_a? Symbol

      case platform
        when :ios, :'iphone os', :'ipad os'
          :ios
        when :android
          :android
        else
          platform
      end
    end

    def symbolize_keys_recursive(hash)
      hash.inject({}) do |h, kv|
        (key, value) = kv
        h[key.to_sym] =
            value.is_a?(Hash) ? symbolize_keys_recursive(value) : value
        h
      end
    end

    extend self
  end
end
