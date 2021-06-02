require 'spec_helper'

describe CandyCheck::PlayStore::Client do
  include WithTempFile
  include WithFixtures

  with_temp_file :cache_file

  subject { CandyCheck::PlayStore::Client.new(fixture_path('play_store', 'google-client-key.json')) }

  it 'fails if authentication fails' do
    mock_authorize!('auth_failure.txt')
    proc { subject.boot! }.must_raise Signet::AuthorizationError
  end

  describe '#verify' do
    it 'allows the client to raise an AuthorizationError on auth failure' do
      bootup!
      
      mock_request!('products_failure.txt')
      assert_raises(Google::Apis::AuthorizationError) { subject.verify('the_package', 'the_id', 'the_token') }
    end

    it 'returns the products call result\'s data for a successful call' do
      bootup!
      mock_request!('products_success.txt')
      result = subject.verify('the_package', 'the_id', 'the_token')
      result.must_be_instance_of Google::Apis::AndroidpublisherV3::ProductPurchase
      
      result.purchase_state.must_equal 0
      result.consumption_state.must_equal 0
      result.developer_payload.must_equal \
        'payload that gets stored and returned'
      result.purchase_time_millis.must_equal 1421676237413
      result.kind.must_equal 'androidpublisher#productPurchase'
    end  
  end

  describe '#verify_subscription' do
    it 'returns the products call result\'s data even if it is a failure' do
      bootup!

      mock_subscriptions_request!('products_failure.txt')
      assert_raises(Google::Apis::AuthorizationError) { subject.verify_subscription('the_package', 'the_id', 'the_token') }
    end
  end

  private

  def bootup!
    mock_authorize!('auth_success.txt')
    subject.boot!
  end

  def mock_authorize!(file)
    stub_request(:post, 'https://www.googleapis.com/oauth2/v4/token')
      .to_return(fixture_content('play_store', file))
  end

  def mock_request!(file)
    stub_request(:get, 'https://www.googleapis.com/androidpublisher/v3/' \
      'applications/the_package/purchases/products/the_id/tokens/the_token')
      .to_return(fixture_content('play_store', file))
  end

  def mock_subscriptions_request!(file)
    stub_request(:get, 'https://www.googleapis.com/androidpublisher/v3/' \
      'applications/the_package/purchases/subscriptions/' \
      'the_id/tokens/the_token')
      .to_return(fixture_content('play_store', file))
  end
end
