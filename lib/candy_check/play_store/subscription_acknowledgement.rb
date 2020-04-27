module CandyCheck
  module PlayStore
    # Acknowledges a purchase token against the Google API
    # The call return either an {Receipt} or an {AcknowledgementFailure}
    class SubscriptionAcknowledgement < Acknowledgement
      # Performs the acknowledgement against the remote server
      # @return [Subscription] if successful
      # @return [AcknowledgementFailure] otherwise
      def call!
        acknowledge!
        Subscription.new(@response)
      rescue Google::Apis::Error => e
        AcknowledgementFailure.new(e)
      end

      private

      def acknowledge!
        @response = @client.acknowledge_subscription_purchase(package, product_id, token)
      end
    end
  end
end
