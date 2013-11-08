module J7W1
  module PushClient
    def create_sns_client(configuration = J7W1.configuration)
      AWS::SNS.new J7W1.configuration.account
    end

    def create_ios_application(name, certs, private_key, options)
      sandbox = !(options[:sandbox] == false)
      configuration = options[:sns_configuration] || J7W1.configuration

      private_key = content_from private_key
      certs = content_from certs

      sns_client = options[:sns_client] || create_sns_client(configuration)

      application_endpoint =
          sns_client.client.create_platform_application(
            name: name, platform: (sandbox ? 'APNS_SANDBOX' : 'APNS'),
            attributes: {
              'PlatformCredential' => private_key,
              'PlatformPrincipal' => certs,
            }
          )
      application_endpoint[:platform_application_arn]
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

    def push(endpoint_arn, platform, options = {})
      return unless endpoint_arn && platform

      message = options[:message]
      badge = options[:badge]
      sound = options[:sound]
      sns_configuration = options[:sns_configuration]
      sns_client = options[:sns_client]

      message_value = {}
      message_value.merge!(alert: message) unless message.blank?
      message_value.merge!(badge: badge) unless badge.blank?
      message_value.merge!(sound: sound) unless sound.blank?

      payload = payload_for(message_value, platform)

      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)
      sns_client.client.publish(
          target_arn: endpoint_arn,
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

    def content_from(argument)
      case argument
        when IO
          argument.read
        when String
          argument
      end
    end

    module_function :create_sns_client, :create_ios_application, :create_device_endpoint, :push,
      :payload_for, :ios_payload_for, :android_payload_for, :content_from
  end
end
