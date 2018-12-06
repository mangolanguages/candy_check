require 'spec_helper'
require 'json'

describe CandyCheck::PlayStore::Subscription do
  let(:subscription_purchase) { Google::Apis::AndroidpublisherV3::SubscriptionPurchase.from_json(JSON.dump(attributes)) }
  subject { CandyCheck::PlayStore::Subscription.new(subscription_purchase) }
  let(:attributes) { active_subscription_data }
  let(:active_subscription_data) do
    {
      'kind' => 'androidpublisher#subscriptionPurchase',
      'startTimeMillis' => timestamp_in_past,
      'expiryTimeMillis' => timestamp_in_future,
      'autoRenewing' => true,
      'priceCurrencyCode' => 'USD',
      'priceAmountMicros' => 19_990_000,
      'countryCode' => 'SN',
      'developerPayload' => 'payload that gets stored and returned',
      'paymentState' => 1,
      'orderId' => 'GPA.1234-1234-1234-11234..0'
    }
  end

  let(:canceled_subscription_data) do
    {
      'kind' => 'androidpublisher#subscriptionPurchase',
      'startTimeMillis' => 1_459_540_113_244,
      'expiryTimeMillis' => 1_462_132_088_610,
      'autoRenewing' => false,
      'priceCurrencyCode' => 'USD',
      'priceAmountMicros' => 19_990_000,
      'countryCode' => 'US',
      'developerPayload' => '',
      'cancelReason' => 0,
      'userCancellationTimeMillis' => 1_543_954_813_520,
      'orderId' => 'GPA.1234-1234-1234-11234..1',
      'linkedPurchaseToken' => 'linked-purchase-token',
      'purchaseType' => 0
    }
  end

  let(:trial_subscription_data) do
    {
      'kind' => 'androidpublisher#subscriptionPurchase',
      'startTimeMillis' => timestamp_in_past,
      'expiryTimeMillis' => timestamp_in_future,
      'autoRenewing' => true,
      'priceCurrencyCode' => 'USD',
      'priceAmountMicros' => 19_990_000,
      'countryCode' => 'US',
      'developerPayload' => '',
      'paymentState' => 2,
      'orderId' => 'GPA.1234-1234-1234-11234'
    }
  end

  let(:timestamp_in_past) { ((Time.now.to_i - 86_400) * 1000).to_s }
  let(:timestamp_in_future) { ((Time.now.to_i + 86_400) * 1000).to_s }

  it 'returns the developer_payload' do
    subject.developer_payload.must_equal \
      'payload that gets stored and returned'
  end

  it 'returns the kind' do
    subject.kind.must_equal 'androidpublisher#subscriptionPurchase'
  end

  it 'returns the start_time_millis' do
    attributes['startTimeMillis'] = '1459540113244'
    subject.start_time_millis.must_equal 1_459_540_113_244
  end

  it 'returns the expiry_time_millis' do
    attributes['expiryTimeMillis'] = '1462132088610'
    subject.expiry_time_millis.must_equal 1_462_132_088_610
  end

  it 'returns the starts_at' do
    attributes['startTimeMillis'] = '1459540113244'
    expected = Time.new(2016, 4, 1, 19, 48, 33, '+00:00')
    assert_instance_of(Time, subject.starts_at)
    subject.starts_at.to_i.must_equal expected.to_i
  end

  it 'returns the expires_at' do
    attributes['expiryTimeMillis'] = '1462132088610'
    expected = Time.new(2016, 5, 1, 19, 48, 8, '+00:00')
    assert_instance_of(Time, subject.expires_at)
    subject.expires_at.to_i.must_equal expected.to_i
  end

  describe 'given an active subscription response' do
    let(:attributes) { active_subscription_data }

    it 'returns true for #auto_renewing?' do
      subject.auto_renewing?.must_be_true
    end

    it 'returns false for #canceled_by_user?' do
      subject.canceled_by_user?.must_be_false
    end

    it 'is expired?' do
      subject.expired?.must_be_false
    end

    it 'returns the payment_state' do
      subject.payment_state.must_equal 1
    end

    it 'considers a payment as valid' do
      subject.payment_received?.must_be_true
    end

    it 'returns the days left until the subscription is overdue' do
      # Set expiration time to 2 days in the future.
      attributes['expiryTimeMillis'] = (Time.now.to_i + 2 * 86_400) * 1000
      subject.overdue_days.must_equal(-2)
    end
  end

  describe 'unexpired and trial subscription' do
    let(:attributes) { trial_subscription_data }

    it 'returns true for auto_renewing?' do
      subject.auto_renewing?.must_be_true
    end

    it 'returns false for expired?' do
      subject.expired?.must_be_false
    end

    it 'returns true for trial?' do
      subject.trial?.must_be_true
    end
  end

  describe 'payment failed, but still in grace period' do
    let(:attributes) do
      active_subscription_data.merge(
        'expiryTimeMillis' => timestamp_in_future,
        'paymentState' => 0
      )
    end

    it 'returns false for expired?' do
      subject.expired?.must_be_false
    end

    it 'returns true for pending_payment?' do
      subject.payment_pending?.must_be_true
    end

    it 'returns true for payment_failed?' do
      subject.payment_failed?.must_be_false
    end
  end

  # https://developer.android.com/google/play/billing/billing_subscriptions
  # See 'Account Hold'
  #
  describe 'payment failed, grace period has ended, account is in "hold"' do
    let(:attributes) do
      active_subscription_data.merge(
        'expiryTimeMillis' => timestamp_in_past,
        'paymentState' => 0
      )
    end

    it 'returns true for expired?' do
      subject.expired?.must_be_true
    end

    it 'returns true for payment_pending?' do
      subject.payment_pending?.must_be_true
    end
  end

  describe 'payment failed, account has passed the hold period and is inactive' do
    let(:attributes) do
      canceled_subscription_data.merge(
        'expiryTimeMillis' => timestamp_in_past,
        'paymentState' => nil,
        'cancelReason' => 1
      )
    end

    it 'returns false for auto_renewing?' do
      subject.auto_renewing?.must_be_false
    end

    it 'returns true for expired?' do
      subject.expired?.must_be_true
    end

    it 'returns false for payment_pending?' do
      subject.payment_pending?.must_be_false
    end

    it 'returns true for payment_failed?' do
      subject.payment_failed?.must_be_true
    end
  end

  describe 'subscription is in a free trial period' do
    let(:attributes) { trial_subscription_data }

    it 'is trial?' do
      subject.trial?.must_be_true
    end
  end
end
