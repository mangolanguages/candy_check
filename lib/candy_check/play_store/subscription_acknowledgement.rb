module CandyCheck
  module PlayStore
    # Acknowledges a purchase token against the Google API
    # The call return {true} or an {AcknowledgementFailure}
    class SubscriptionAcknowledgement < Acknowledgement
      # Performs the acknowledgement against the remote server
      # @return true if successful
      # @return [AcknowledgementFailure] otherwise
      def call!
        acknowledge!
        true
      rescue Google::Apis::Error => e
        AcknowledgementFailure.new(e)
      end

      private

      def acknowledge!
        # This client call has a nil return value on success.
        @client.acknowledge_purchase_subscription(package, product_id, token)
      end
    end
  end
end
