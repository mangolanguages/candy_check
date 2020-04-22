module CandyCheck
  module PlayStore
    # A client which uses the official Google API SDK to authenticate
    # and request product information from Google's API.
    #
    # @example Usage
    #   config = ClientConfig.new({...})
    #   client = Client.new(config)
    #   client.boot! # a single time
    #   client.verify('my.bundle', 'product_1', 'a-very-long-secure-token')
    #   # ... multiple calls from now on
    #   client.verify('my.bundle', 'product_1', 'another-long-token')
    class Client
      # Error thrown if the discovery of the API wasn't successful
      class DiscoveryError < RuntimeError; end

      # API endpoint
      API_URL      = 'https://accounts.google.com/o/oauth2/token'.freeze
      # API scope for Android services
      API_SCOPE    = 'https://www.googleapis.com/auth/androidpublisher'.freeze

      # API discovery namespace
      API_DISCOVER = 'androidpublisher'.freeze
      # API version
      API_VERSION  = 'v2'.freeze

      # Initializes a client using a configuration.
      # @param config_path [path/to/client_secrets.json]
      def initialize(client_secrets_path)
        @client_secrets_path = client_secrets_path
      end

      # Boots a client by discovering the API's services and then authorizes
      # by fetching an access token.
      # If the config has a cache_file the client tries to load discovery
      def boot!
        @api_client = Google::Apis::AndroidpublisherV3::AndroidPublisherService.new
        authorize!
      end
      

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param product_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [ProductPurchase] result of the API call
      def verify(package, product_id, token)
        @api_client.get_purchase_product(
          package,
          product_id,
          token
        )
      end

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param subscription_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [SubscriptionPurchase] result of the API call
      def verify_subscription(package, subscription_id, token)
        @api_client.get_purchase_subscription(
          package,
          subscription_id,
          token
        )
      end

      # Acknowledges a subscription purchase.
      # @param package [String] the app's package name
      #   for example, 'com.some.thing').
      # @param subscription_id [String] the subscription's ID
      # @param token [String] the purchase token
      # @return [void]
      def acknowledge_subscription_purchase(package, subscription_id, token)
        @api_client.acknowledge_purchase_subscription(
          package,
          subscription_id,
          token
        )
      end

      private

      attr_reader :config, :api_client

      def authorize!
        @api_client.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(@client_secrets_path),
          scope: API_SCOPE
        )  
        @api_client.authorization.fetch_access_token!
      end

    end
  end
end
