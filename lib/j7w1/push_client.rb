module J7W1
  module PushClient
    def self.create_sns_client(configuration = J7W1.configuration)
      AWS::SNS.new J7W1.configuration.account
    end

    def push(terminal, options = {})
      message = options[:message]
      badge = options[:badge]
      sound = options[:sound]
      sns_configuration = options[:sns_configuration]
      sns_client = options[:sns_client]

      return unless endpoint = terminal.sns_arn

      message_value = {}
      message_value.merge!(alert: message) unless message.blank?
      message_value.merge!(badge: badge) unless badge.blank?
      message_value.merge!(sound: sound) unless sound.blank?


      payload = payload_for(message_value, endpoint.platform)

      sns_client = J7W1.create_sns(sns_configuration || J7W1.configuration)
      sns_client.sns.client.publish(
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
