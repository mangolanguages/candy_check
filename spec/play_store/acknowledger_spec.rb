require 'spec_helper'

describe CandyCheck::PlayStore::Acknowledger do
  subject { CandyCheck::PlayStore::Acknowledger.new(config_key_path) }
  let(:config_key_path) { 'path/to/google_play.json' }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  it 'holds the config' do
    subject.config_key_path.must_be_same_as config_key_path
  end

  it 'requires a boot before acknowledgement' do
    proc do
      subject.acknowledge(package, product_id, token)
    end.must_raise CandyCheck::PlayStore::Acknowledger::BootRequiredError
  end

  it 'it configures and boots a client but raises on second boot!' do
    with_mocked_client do
      subject.boot!
      @client.config_key_path.must_be_same_as config_key_path
      @client.booted.must_be_true
    end

    proc do
      subject.boot!
    end.must_raise CandyCheck::PlayStore::Acknowledger::BootRequiredError
  end

  it 'uses a acknowledger when booted' do
    result = :stubbed
    with_mocked_client do
      subject.boot!
    end
    with_mocked_acknowledger(result) do
      subject.acknowledge(package, product_id, token).must_be_same_as result

      assert_recorded(
        [@client, package, product_id, token]
      )
    end
  end

  it 'uses a subscription acknowledger when booted' do
    result = :stubbed
    with_mocked_client do
      subject.boot!
    end
    with_mocked_acknowledger(result) do
      subject.acknowledge_subscription(
        package, product_id, token
      ).must_be_same_as result

      assert_recorded(
        [@client, package, product_id, token]
      )
    end
  end

  private

  def with_mocked_acknowledger(*results)
    @recorded ||= []
    stub = proc do |*args|
      @recorded << args
      DummyPlayStoreAcknowledgement.new(*args).tap { |v| v.results = results }
    end
    CandyCheck::PlayStore::Acknowledgement.stub :new, stub do
      yield
    end
  end

  def with_mocked_client
    stub = proc do |*args|
      @client = DummyPlayStoreClient.new(*args)
    end
    CandyCheck::PlayStore::Client.stub :new, stub do
      yield
    end
  end

  def assert_recorded(*calls)
    @recorded.must_equal calls
  end

  DummyPlayStoreAcknowledgement = Struct.new(:client, :package,
                                          :product_id, :token) do
    attr_accessor :results
    def call!
      results.shift
    end
  end

  DummyPlayStoreClient = Struct.new(:config_key_path) do
    attr_reader :booted
    def boot!
      @booted = true
    end
  end
end
