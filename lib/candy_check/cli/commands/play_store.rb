module CandyCheck
  module CLI
    module Commands
      # Command to verify an PlayStore purchase
      class PlayStore < Base
        # Prepare a verification run from the terminal
        # @param package [String]
        # @param product_id [String]
        # @param token [String]
        # @param client_secrets_path [String]
        def initialize(package, product_id, token, client_secrets_path)
          @package = package
          @product_id = product_id
          @token = token
          super({ client_secrets_path: client_secrets_path })
        end

        # Print the result of the verification to the terminal
        def run
          verifier = CandyCheck::PlayStore::Verifier.new(options[:client_secrets_path])
          verifier.boot!
          result = verifier.verify(@package, @product_id, @token)
          out.print "#{result.class}:"
          out.pretty result
        end
      end
    end
  end
end
