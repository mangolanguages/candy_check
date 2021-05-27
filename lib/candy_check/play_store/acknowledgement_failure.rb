module CandyCheck
  module PlayStore
    # Represents a failing call against the Google API server
    class AcknowledgementFailure

      attr_reader :error

      # Initializes a new instance based on an instance of
      # Google::Apis::ClientError
      # @param error [Google::Apis::ClientError]
      def initialize(error)
        @error = error
      end

      # The code of the failure
      # @return [Fixnum]
      def code
        error.status_code
      end

      # The message of the failure
      # @return [String]
      def message
        error.message || 'Unknown error'
      end

    end
  end
end
