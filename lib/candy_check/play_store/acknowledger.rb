module CandyCheck
  module PlayStore
    # Acknowledges purchased subscriptions with the Google API.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Acknowledger
      # Error thrown when the verifier isn't booted before the first
      # verification check or on double invocation
      class BootRequiredError < RuntimeError; end

      # @return [Config] the current configuration
      attr_reader :config_key_path

      # Initializes a new verifier for the application which is bound
      # to a configuration
      # @param config [Config]
      def initialize(config_key_path)
        @config_key_path = config_key_path
      end

      # Boot the module
      def boot!
        boot_error('You\'re only allowed to boot the acknowledger once') if booted?
        @client = Client.new(config_key_path)
        @client.boot!
      end

      # Contacts the Google API and acknowledges the product purchase
      # @param package [String] to query
      # @param product_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [AcknowledgementFailure] otherwise
      def acknowledge(package, product_id, token)
        check_boot!
        acknowledgement = Acknowledgement.new(@client, package, product_id, token)
        acknowledgement.call!
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param subscription_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def acknowledge_subscription(package, subscription_id, token)
        check_boot!
        v = SubscriptionAcknowledgement.new(
          @client, package, subscription_id, token
        )
        v.call!
      end

      private

      def booted?
        instance_variable_defined?(:@client)
      end

      def check_boot!
        return if booted?
        boot_error 'You need to boot the acknowledger service first: '\
                   'CandyCheck::PlayStore::Verifier#boot!'
      end

      def boot_error(message)
        raise BootRequiredError, message
      end
    end
  end
end
