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

end
