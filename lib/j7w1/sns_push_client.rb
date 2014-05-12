module J7W1
  module SNSPushClient
    def create_sns_client(configuration = J7W1.configuration)
      AWS::SNS.new configuration.account
    end

    APNS_MAX_MESSAGE_SIZE = 40

    APS_TABLE = {
        message: :alert,
        badge: :badge,
        sound: :sound,
    }.freeze

    ANDROID_TABLE = {
        message: :message,
        badge: :badge,
        sound: :sound,
        data: :data,
    }.freeze

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

    def destroy_application_endpoint(arn, options)
      configuration = options[:sns_configuration] || J7W1.configuration
      client = options[:sns_client] || create_sns_client(configuration)

      client.client.delete_platform_application(platform_application_arn: arn)
    end

    def create_device_endpoint(device_identifier, platform, options = {})
      custom_user_data = options[:custom_user_data]
      sns_configuration = options[:sns_configuration] || J7W1.configuration
      sns_client = options[:sns_client]

      sns_client ||= create_sns_client(sns_configuration)

      app_arn =
          case platform
            when :ios
              sns_configuration.ios_endpoint.arn
            when :android
              sns_configuration.android_endpoint.arn
            else

          end

      endpoint =
        sns_client.client.create_platform_endpoint(
          platform_application_arn: app_arn,
          token: device_identifier,
          custom_user_data: custom_user_data
        )
      endpoint[:endpoint_arn]
    end

    def destroy_device_endpoint(device_endpoint_arn, options = {})
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
      data = options[:data]
      sns_configuration = options[:sns_configuration]
      sns_client = options[:sns_client]

      message_value = {}
      message_value.merge!(message: message) unless message.blank?
      message_value.merge!(badge: badge) unless badge.blank?
      message_value.merge!(sound: sound) unless sound.blank?

      payload = payload_for(message_value, data, platform)

      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)
      client = sns_client.client

      enabled = (client.get_endpoint_attributes(endpoint_arn: endpoint_arn)[:attributes]['Enabled'] == 'true')
      unless enabled
        client.set_endpoint_attributes endpoint_arn: endpoint_arn, attributes: {'Enabled' => 'true'}
      end

      client.publish(
          target_arn: endpoint_arn,
          message: payload.to_json,
          message_structure: 'json',
      )
    end

    private
    def payload_for(message_value, data, platform)
      case platform.to_sym
        when :ios
          ios_payload_for(message_value, data)
        when :android
          android_payload_for(message_value, data)
      end
    end

    def ios_payload_for(message_value, data)
      prefix = J7W1.configuration.ios_endpoint.sandbox? ?
          :APNS_SANDBOX : :APNS

      if message_value[:message] && message_value[:message].length > APNS_MAX_MESSAGE_SIZE
        message_value[:message] = message_value[:message][0...(APNS_MAX_MESSAGE_SIZE - 3)] + '...'
      end

      content = {
          aps: message_content_with_table(message_value, APS_TABLE),
      }
      content.merge! data: data if data

      {prefix => content.to_json}
    end

    def android_payload_for(message_value, data)
      message_value.merge!(data: data)
      {
          GCM: {
              data: message_content_with_table(message_value, ANDROID_TABLE)
          }.to_json
      }
    end

    def message_content_with_table(content, table)
      table.keys.reduce({}) do |h, key|
        h[table[key]] = content[key]
        h
      end
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
      :payload_for, :ios_payload_for, :android_payload_for, :content_from, :message_content_with_table,
      :destroy_device_endpoint, :destroy_application_endpoint
  end
end
