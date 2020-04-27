module CandyCheck
  module PlayStore
    # Acknowedges a subscription purchase with the Google API.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Acknowledgement
      # @return [String] the package which will be queried
      attr_reader :package
      # @return [String] the item id which will be queried
      attr_reader :product_id
      # @return [String] the token for authentication
      attr_reader :token

      # Initializes a new call to the API
      # @param client [Client] a shared client instance
      # @param package [String]
      # @param product_id [String]
      # @param token [String]
      def initialize(client, package, product_id, token)
        @client = client
        @package = package
        @product_id = product_id
        @token = token
      end

      # Performs the verification against the remote server
      # @return [Receipt] if successful
      # @return [AcknowledgementFailure] otherwise
      def call!
        acknowledge!
        Receipt.new(@response)
      rescue Google::Apis::Error => e
        AcknowledgementFailure.new(e)
      end

      private

      def acknowledge!
        @response = @client.acknowledge(package, product_id, token)
      end
    end
  end
end
