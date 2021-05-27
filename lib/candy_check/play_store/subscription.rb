module CandyCheck
  module PlayStore
    # Describes a successfully validated subscription
    class Subscription
      
      # The payment of the subscription is pending (paymentState)
      PAYMENT_PENDING = 0
      # The payment of the subscript is received (paymentState)
      PAYMENT_RECEIVED = 1
      # This subscription is a free trial (paymentState)
      PAYMENT_TRIAL = 2

      # The subscription was canceled by the user (cancelReason)
      PAYMENT_CANCELED = 0
      # The payment failed during processing (cancelReason)
      PAYMENT_FAILED = 1

      # The subscription purchase has been acknowledged
      ACKNOWLEDGED = 1

      # The subscription purchase has not yet been acknowledged
      NOT_ACKNOWLEDGED = 0

      # Initializes a new instance which bases on a JSON result
      # from Google's servers
      # @param attributes [Hash]
      def initialize(receipt)
        @receipt = receipt
      end

      # Check if the expiration date is passed
      # @return [bool]
      def expired?
        overdue_days > 0
      end

      # Check if in trial. This is actually not given by Google, but we assume
      # that it is a trial going on if the paid amount is 0 and
      # renewal is activated.
      # @return [bool]
      def trial?
        @receipt.payment_state == PAYMENT_TRIAL
      end

      # see if payment is ok
      # @return [bool]
      def payment_received?
        @receipt.payment_state == PAYMENT_RECEIVED
      end

      # see if payment is pending
      # @return [bool]
      def payment_pending?
        @receipt.payment_state == PAYMENT_PENDING
      end

      # see if payment has failed according to Google
      # @return [bool]
      def payment_failed?
        @receipt.cancel_reason == PAYMENT_FAILED
      end

      # see if this the user has canceled its subscription
      # @return [bool]
      def canceled_by_user?
        @receipt.cancel_reason == PAYMENT_CANCELED
      end

      # Get number of overdue days. If this is negative, it is not overdue.
      # @return [Integer]
      def overdue_days
        (Date.today - expires_at.to_date).to_i
      end

      # Get the auto renewal status as given by Google
      # @return [bool] true if renewing automatically, false otherwise
      def auto_renewing?
        @receipt.auto_renewing?
      end

      # Get the payment state as given by Google
      # @return [Integer]
      def payment_state
        @receipt.payment_state
      end

      # Get the price amount for the subscription in micros in the payed
      # currency
      # @return [Fixnum]
      def price_amount_micros
        @receipt.price_amount_micros
      end

      # Get the cancel reason, as given by Google
      # @return [Integer]
      def cancel_reason
        @receipt.cancel_reason
      end

      # Get the kind of subscription as stored in the android publisher service
      # @return [String]
      def kind
        @receipt.kind
      end

      # Get developer-specified supplemental information about the order
      # @return [String]
      def developer_payload
        @receipt.developer_payload
      end

      # Get the currency code in ISO 4217 format, e.g. "GBP" for British pounds
      # @return [String]
      def price_currency_code
        @receipt.price_currency_code
      end

      # Get start time for subscription in milliseconds since Epoch
      # @return [Integer]
      def start_time_millis
        @receipt.start_time_millis
      end

      # Get expiry time for subscription in milliseconds since Epoch
      # @return [Integer]
      def expiry_time_millis
        @receipt.expiry_time_millis
      end

      # Get current acknowledgement state for subscription. 
      # @return [Integer] one of:
      #  - ACKNOWLEDGED = 1
      #  - NOT_ACKNOWLEDGED = 0
      def acknowledgement_state
        @receipt.acknowledgement_state
      end

      # Get start time in UTC
      # @return [DateTime]
      def starts_at
        Time.at(start_time_millis / 1000)
      end

      # Get expiration time in UTC
      # @return [DateTime]
      def expires_at
        Time.at(expiry_time_millis / 1000)
      end
    end
  end
end
