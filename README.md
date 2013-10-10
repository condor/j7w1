# J7W1

A gem to send the push notification to mobile app via Amazon Simple Notification Service (SNS). Currently supports only iOS platform, but the support for Android is also scheduled.

## Installation

Add this line to your application's Gemfile:

    gem 'j7w1'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install j7w1

## Usage

First, configure your app.

    J7W1.configure 'config.yml'

Or, you may configure programatically as below:

    configuration = {
        app_endpoint: {
            ios: {arn: ...},
        },
        account: {
            ...
        }
    }
    J7W1.configure 

Configuration is expected to have the structure as below:

    app_endpoint:
        ios:
            arn: "<The ARN of your app.>"
    account:
        access_key_id: "<Your Access Key>"
        secret_access_key: "<Your Secret Key>"
        region: '<Your Region>'


If you use this with RoR, top-level environmental definition can be available.

### Registering device to SNS

J7W1::PushClient.create_device_endpoint.

    J7W1::PushClient.create_device_identifier device_identifier, platform

This method returns the arn registered.

### Sending push

J7W1::PushClient.push.

    J7W1::PushClient.push endpoint_arn, platform, message: some_message, badge: badge_count, sound: xxx

endpoint_arn should be the return value of the :create_device_endpoint above.

## RoR Integration

The generator j7w1:model must be useful for you. It provides the items below:

1. The model J7W1ApplicationDevice. This model enables you to store the device information and to push easily.
2. The migration for the model above.
3. Asyncronous SNS Syncing support. Currently delayed_job and sidekiq are supported. If you use this feature, invoke j7w1:model generation with --async-engine=(delayed_job|sidekiq).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

TOYODA Naoto https://github.com/condor