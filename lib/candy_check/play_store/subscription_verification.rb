module CandyCheck
  module PlayStore
    # Verifies a purchase token against the Google API
    # The call return either an {Receipt} or an {VerificationFailure}
    class SubscriptionVerification < Verification
      # Performs the verification against the remote server
      # @return [Subscription] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        Subscription.new(@response)
      rescue Google::Apis::Error => e
        VerificationFailure.new(e)
      end

      private

      def verify!
        @response = @client.verify_subscription(package, product_id, token)
      end
    end
  end
end
