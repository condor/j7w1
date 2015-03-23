module J7W1
  module SNSPushClient
    def create_sns_client(configuration = J7W1.configuration)
      AWS::SNS.new configuration.account
    end

    APNS_MAX_PAYLOAD = 256

    SHORTEN_REPLACEMENT = '...'.freeze
    SHORTEN_REPLACEMENT_LENGTH = SHORTEN_REPLACEMENT.length

    INPUT_PAYLOAD_TABLE = {
      ios: {
        message: :alert,
        badge: :badge,
        sound: :sound,
      }.freeze,
      android: {
        message: :message,
        badge: :badge,
        sound: :sound,
        data: :data,
      }.freeze,
    }.freeze

    DEFAULT_SOUND_VALUE = {
      android: true,
      ios: 'default',
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

    def create_topic(name, options)
      sns_client = options[:sns_client]
      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)

      sns_client.topics.create name
    end

    def subscribe_topic(topic_name, endpoint_arn, options)
      sns_client = options[:sns_client]
      sns_client ||= create_sns_client(sns_configuration || J7W1.configuration)

      sns_client.topics[name]
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

      content = {
          aps: message_content(message_value, platform: :ios),
      }
      content.merge! data: data if data

      {prefix => ios_truncated_payload(content)}
    end

    def ios_truncated_payload(data)
      payload = data.to_json

      # Truncation is skipped when the payload is sufficiently lightweight.
      return payload if (limit_break = payload.bytesize - APNS_MAX_PAYLOAD) <= 0

      # Raise error if shortening of the alert cannot make the payload sufficiently short.
      size_to_reduce = limit_break + SHORTEN_REPLACEMENT_LENGTH
      raise "Payload is too heavy (original size: #{payload.bytesize}, except message: (#{payload.bytesize - data[:alert].to_s.bytesize}))" unless
        data[:alert] && data[:alert].bytesize > size_to_reduce

      # Chopping the alert from its last -> first to avoid destroying the character's border
      # and keep its content as long as possible.
      chopped_length = 0
      chopped_count = 0
      while chopped_length < size_to_reduce
        chopped_length += data[:alert][-1].bytesize
        chopped_count += 1
      end
      data[:alert][-chopped_count..-1] = SHORTEN_REPLACEMENT
      # Problem won't be occur because at least a character is truncated.

      data.to_json
    end

    def android_payload_for(message_value, data)
      message_value.merge!(data: data)
      {
          GCM: {
              data: message_content(message_value, platform: :android),
          }.to_json
      }
    end

    def message_content(content, platform: nil)
      table = INPUT_PAYLOAD_TABLE[platform]

      content[:sound] = DEFAULT_SOUND_VALUE[platform] if content[:sound] == true

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
      :payload_for, :ios_payload_for, :android_payload_for, :content_from, :message_content,
      :destroy_device_endpoint, :destroy_application_endpoint, :ios_truncated_payload
  end
end
