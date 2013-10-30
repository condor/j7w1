module J7W1
  module Util
    def normalize_platform(platform)
      case platform
      when 'iPhone OS'
        :ios
      end
    end

    instance_methods(false).each{|m|module_function m}
  end
end
