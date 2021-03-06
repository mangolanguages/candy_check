require 'spec_helper'

describe CandyCheck::PlayStore::SubscriptionVerification do
  subject do
    CandyCheck::PlayStore::SubscriptionVerification.new(
      client, package, product_id, token
    )
  end
  let(:client)     { DummyGoogleSubsClient.new(response) }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }
  let(:acknowledgement_state) { 1 }

  describe 'valid' do
    let(:response) do
      Google::Apis::AndroidpublisherV3::SubscriptionPurchase.from_json(
        JSON.dump(
          'kind' => 'androidpublisher#subscriptionPurchase',
          'startTimeMillis' => 1_459_540_113_244,
          'expiryTimeMillis' => 1_462_132_088_610,
          'autoRenewing' => false,
          'developerPayload' => 'payload that gets stored and returned',
          'cancelReason' => 0,
          'paymentState' => '1',
          'acknowledgementState' => 1
        )
      )
    end

    it 'calls the client with the correct paramters' do
      subject.call!
      client.package.must_equal package
      client.product_id.must_equal product_id
      client.token.must_equal token
    end

    it 'returns a subscription' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::Subscription
      result.expired?.must_be_true
      result.acknowledgement_state.must_equal acknowledgement_state
    end
  end

  describe 'failure' do
    let(:response) { Google::Apis::ClientError.new(RuntimeError.new('The current user has insufficient permissions'), status_code: 401) }

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal 401
    end
  end

  private

  DummyGoogleSubsClient = Struct.new(:response) do
    attr_reader :package, :product_id, :token

    def boot!; end

    def verify_subscription(package, product_id, token)
      @package = package
      @product_id = product_id
      @token = token

      # Are we expecting an Exception?
      raise response if response.is_a?(Google::Apis::ClientError)

      response
    end
  end
end
