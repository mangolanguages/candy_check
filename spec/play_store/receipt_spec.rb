require 'spec_helper'
require 'json'

describe CandyCheck::PlayStore::Receipt do
  let(:product_purchase) { Google::Apis::AndroidpublisherV3::ProductPurchase.from_json(JSON.dump(attributes)) }
  subject { CandyCheck::PlayStore::Receipt.new(product_purchase) }

  describe 'valid and non-consumed product' do
    let(:attributes) do
      {
        'kind' => 'androidpublisher#productPurchase',
        'purchaseTimeMillis' => 1_421_676_237_413,
        'purchaseState' => 0,
        'consumptionState' => 0,
        'developerPayload' => 'payload that gets stored and returned'
      }
    end

    it 'is valid?' do
      subject.valid?.must_be_true
    end

    it 'is not consumed' do
      subject.consumed?.must_be_false
    end

    it 'returns the purchase_state' do
      subject.purchase_state.must_equal 0
    end

    it 'returns the consumption_state' do
      subject.consumption_state.must_equal 0
    end

    it 'returns the developer_payload' do
      subject.developer_payload.must_equal \
        'payload that gets stored and returned'
    end

    it 'returns the kind' do
      subject.kind.must_equal \
        'androidpublisher#productPurchase'
    end

    it 'returns the purchase_time_millis' do
      subject.purchase_time_millis.must_equal 1_421_676_237_413
    end

    it 'returns the purchased_at' do
      expected = Time.new(2015, 1, 19, 14, 3, 57, '+00:00')
      assert_instance_of(Time, subject.purchased_at)
      subject.purchased_at.to_i.must_equal expected.to_i
    end
  end

  describe 'valid and consumed product' do
    let(:attributes) do
      {
        'kind' => 'androidpublisher#productPurchase',
        'purchaseTimeMillis' => 1_421_676_237_413,
        'purchaseState' => 0,
        'consumptionState' => 1,
        'developerPayload' => 'payload that gets stored and returned'
      }
    end

    it 'is valid?' do
      subject.valid?.must_be_true
    end

    it 'is consumed?' do
      subject.consumed?.must_be_true
    end
  end

  describe 'non-valid product' do
    let(:attributes) do
      {
        'kind' => 'androidpublisher#productPurchase',
        'purchaseTimeMillis' => 1_421_676_237_413,
        'purchaseState' => 1,
        'consumptionState' => 0,
        'developerPayload' => 'payload that gets stored and returned'
      }
    end

    it 'is valid?' do
      subject.valid?.must_be_false
    end
  end
end
