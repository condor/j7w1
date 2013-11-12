module J7W1
  module Util
    def normalize_platform(platform)
      platform = platform.to_s.downcase.to_sym unless platform.is_a? Symbol

      case platform
      when :ios, :'iphone os', :'ipad os'
        :ios
      else
        platform
      end
    end

    instance_methods(false).each{|m|module_function m}
  end
end
