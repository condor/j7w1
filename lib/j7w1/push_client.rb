module J7W1::Sns
  module PushClient
    def push(destination, message: nil, badge: nil, sound: nil, sns: nil)
      sns ||= J7W1::Sns.create_sns

      return unless endpoint = destination.sns_endpoint

      message_value = {}
      message_value.merge!(alert: message) unless message.blank?
      message_value.merge!(badge: badge) unless badge.blank?
      message_value.merge!(sound: sound) unless sound.blank?


      payload = payload_for(message_value, endpoint.platform)
      sns.client.publish(
          target_arn: endpoint.arn,
          message: payload.to_json,
          message_structure: 'json',
      )
    end

    private
    def payload_for(message_value, platform)
      case platform
        when 'ios'
          ios_payload_for(message_value)
        when 'android'
          android_payload_for(message_value)
      end
    end

    def ios_payload_for(message_value)
      prefix = J7W1::Sns.configuration.ios_endpoint.sandbox? ?
          :APNS_SANDBOX : :APNS
      {prefix => {aps: message_value}.to_json}
    end

    def android_payload_for(message_value)
      # TODO Android Push Implementation
    end

    module_function :push, :payload_for, :ios_payload_for, :android_payload_for
  end
end
