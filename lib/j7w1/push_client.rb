module J7W1
  module PushClient
    def create_sns_client(configuration = J7W1.configuration)
      AWS::SNS.new J7W1.configuration.account
    end

    def create_device_endpoint(device_identifier, platform, options = {})
      custom_user_data = options[:custom_user_data]
      sns_configuration = options[:sns_configuration]
      sns_client = options[:sns_client]

      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)

      sns_config = J7W1.configuration
      app_arn = platform == :ios ?  sns_config.ios_endpoint.arn :
        sns_config.android_endpoint.arn

      endpoint =
        sns_client.client.create_platform_endpoint(
          platform_application_arn: app_arn,
          token: device_identifier,
          custom_user_data: custom_user_data
        )
      endpoint[:endpoint_arn]
    end

    def destroy_endpoint(device_endpoint_arn, options = {})
      sns_client = options[:sns_client]
      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)

      sns_client.client.delete_endpoint(endpoint_arn: device_endpoint_arn)
    rescue
      nil
    end

    def push(device, options = {})
      message = options[:message]
      badge = options[:badge]
      sound = options[:sound]
      sns_configuration = options[:sns_configuration]
      sns_client = options[:sns_client]

      return unless endpoint = device.sns_arn

      message_value = {}
      message_value.merge!(alert: message) unless message.blank?
      message_value.merge!(badge: badge) unless badge.blank?
      message_value.merge!(sound: sound) unless sound.blank?


      payload = payload_for(message_value, endpoint.platform)

      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)
      sns_client.client.publish(
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

    module_function :create_sns_client, :create_device_endpoint, :push,
      :payload_for, :ios_payload_for, :android_payload_for
  end
end
