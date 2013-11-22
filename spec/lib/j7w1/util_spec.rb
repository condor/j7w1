require File.expand_path(File.join(File.dirname(__FILE__), '../../spec_helper'))

describe J7W1::Util do

  describe :symbolize_keys_recursive do
    subject{
      Object.new.tap{|o|o.extend J7W1::Util }
    }

    context "should return the hash whose keys are converted to symbol recursively" do
      specify do
        expect(subject.symbolize_keys_recursive({'aaa' => 1, :bbb => 2, '3' => 4})).to eql({aaa: 1, bbb: 2, :'3' => 4})
      end

      specify do
        expect(subject.symbolize_keys_recursive({'aaa' => 1, :bbb => 2, '3' => {'aaa' => 5, :'bbb' => 10}})).to eql({aaa: 1, bbb: 2, :'3' => {aaa: 5, bbb: 10}})
      end
    end
  end
end