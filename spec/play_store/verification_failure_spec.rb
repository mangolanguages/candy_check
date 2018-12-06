require 'spec_helper'

describe CandyCheck::PlayStore::VerificationFailure do
  subject { CandyCheck::PlayStore::VerificationFailure.new(error) }

  describe 'ClientError' do
    let(:error) do
      Google::Apis::ClientError.new(RuntimeError.new("The current user has insufficient permissions"), status_code: 401)
    end

    it 'returns the code' do
      subject.code.must_equal 401
    end

    it 'returns the message' do
      subject.message.must_equal 'The current user has insufficient permissions'
    end
  end

end
