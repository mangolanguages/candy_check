require 'spec_helper'

describe CandyCheck::PlayStore::SubscriptionAcknowledgement do
  subject do
    CandyCheck::PlayStore::SubscriptionAcknowledgement.new(
      client, package, product_id, token
    )
  end

  let(:client)     { DummyGoogleSubAckClient.new(response) }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }
  let(:response) { }

  describe 'valid' do
    it 'calls the client with the correct paramters' do
      subject.call!
      client.package.must_equal package
      client.product_id.must_equal product_id
      client.token.must_equal token
    end
  end

  describe 'failure' do
    let(:response) { Google::Apis::ClientError.new(RuntimeError.new('The current user has insufficient permissions'), status_code: 401) }

    it 'returns a Acknowledgement failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::AcknowledgementFailure
      result.code.must_equal 401
    end
  end

  private

  DummyGoogleSubAckClient = Struct.new(:response) do
    attr_reader :package, :product_id, :token

    def boot!; end

    def acknowledge_subscription_purchase(package, product_id, token)
      @package = package
      @product_id = product_id
      @token = token

      # Are we expecting an Exception?
      raise response if response.is_a?(Google::Apis::ClientError)

      response
    end
  end
end
