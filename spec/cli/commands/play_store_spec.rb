require 'spec_helper'

describe CandyCheck::CLI::Commands::PlayStore do
  include WithCommand
  subject { CandyCheck::CLI::Commands::PlayStore }
  let(:arguments) { [package, product_id, token, client_secrets_path] }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }
  let(:client_secrets_path) { 'path/to/key.json' }

  before do
    stub = proc do |*args|
      @verifier = DummyPlayStoreVerifier.new(*args)
    end
    CandyCheck::PlayStore::Verifier.stub :new, stub do
      run_command!
    end
  end

  it 'calls and outputs the verifier' do
    @verifier.public_send(:config_key_path).must_equal client_secrets_path
    @verifier.arguments.must_equal [package, product_id, token]
    out.must_be 'Hash:', result: :stubbed
  end

  private

  DummyPlayStoreVerifier = Struct.new(:config_key_path) do
    attr_reader :arguments, :booted

    def boot!
      @booted = true
    end

    def verify(*arguments)
      @arguments = arguments
      { result: :stubbed }
    end
  end
end
