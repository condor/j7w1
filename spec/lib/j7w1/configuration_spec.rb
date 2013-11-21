require File.expand_path(File.join(File.dirname(__FILE__), '../../spec_helper'))

describe J7W1::Configuration  do
  describe :ios_endpoint do


    shared_examples_for 'sandbox_confirmation' do
      subject {
        J7W1::Configuration.new(
          app_endpoint: {
            ios: {
              arn: arn,
            },
          }
        )
      }

      specify { expect(subject.ios_endpoint.arn).to eql(arn) }
      specify { expect(!!subject.ios_endpoint.sandbox?).to eql(sandbox) }
    end

    describe 'sandbox arn' do
      let(:sandbox){true}
      let(:arn){'arn:aws:sns:ap-northeast-1:1234567:app/APNS_SANDBOX/test'}
      it_should_behave_like 'sandbox_confirmation'
    end

    describe 'production arn' do
      let(:sandbox){false}
      let(:arn){'arn:aws:sns:ap-northeast-1:1234567:app/APNS/test'}
      it_should_behave_like 'sandbox_confirmation'
    end
  end

  describe :android_endpoint do
    subject {
      J7W1::Configuration.new(
        app_endpoint: {
          android: {
            arn: arn,
          },
        }
      )
    }
    let(:arn){'arn:aws:sns:ap-northeast-1:1234567:app/ANDROID/test'}
    specify 'arn should return the specified configuration value' do
      expect(subject.android_endpoint.arn).to eql(arn)
    end
  end

  describe :account do
    subject {
      J7W1::Configuration.new(
        account: {
          region: region,
          access_key_id: access_key_id,
          secret_access_key: secret_access_key,
        }
      )
    }
    let(:region){'ap-northeast-1'}
    let(:access_key_id){'access_key_id_1'}
    let(:secret_access_key){'secret_access_key_1'}

    describe 'should return a hash with values under :account given on initialization' do
      specify{expect(subject.account).to be_kind_of Hash}
      specify{expect(subject.account[:region]).to eql(region)}
      specify{expect(subject.account[:access_key_id]).to eql(access_key_id)}
      specify{expect(subject.account[:secret_access_key]).to eql(secret_access_key)}
    end

    describe 'its accessors should return the values which are correspondent to the key' do
      specify{expect(subject.account.region).to eql(region)}
      specify{expect(subject.account.access_key_id).to eql(access_key_id)}
      specify{expect(subject.account.secret_access_key).to eql(secret_access_key)}
    end
  end

end
