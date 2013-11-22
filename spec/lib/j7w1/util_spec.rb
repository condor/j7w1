require File.expand_path(File.join(File.dirname(__FILE__), '../../spec_helper'))

describe J7W1::Util do
  subject{
    Object.new.tap{|o|o.extend J7W1::Util }
  }

  describe :symbolize_keys_recursive do

    context "should return the hash whose keys are converted to symbol recursively" do
      specify do
        expect(subject.symbolize_keys_recursive({'aaa' => 1, :bbb => 2, '3' => 4})).to eql({aaa: 1, bbb: 2, :'3' => 4})
      end

      specify do
        expect(subject.symbolize_keys_recursive({'aaa' => 1, :bbb => 2, '3' => {'aaa' => 5, :'bbb' => 10}})).to eql({aaa: 1, bbb: 2, :'3' => {aaa: 5, bbb: 10}})
      end
    end
  end

  describe :normalize_platform do
    context 'can normalize ios-like platform symbol to :ios' do

      shared_examples_for 'into ios' do
        specify{expect(subject.normalize_platform(platform_string)).to eql(:ios)}
      end

      context '"iPad OS" is given' do
        let(:platform_string){'iPad OS'}
        it_behaves_like 'into ios'
      end

      context '"iPhone OS" is given' do
        let(:platform_string){'iPhone OS'}
        it_behaves_like 'into ios'
      end

      context '"iOS" is given' do
        let(:platform_string){'iOS'}
        it_behaves_like 'into ios'
      end

    end
  end
end