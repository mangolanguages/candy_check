require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'google/apis/androidpublisher_v3'
require 'google/apis/errors'

require 'candy_check/play_store/client'
require 'candy_check/play_store/receipt'
require 'candy_check/play_store/subscription'
require 'candy_check/play_store/verification'
require 'candy_check/play_store/acknowledgement'
require 'candy_check/play_store/subscription_verification'
require 'candy_check/play_store/subscription_acknowledgement'
require 'candy_check/play_store/verification_failure'
require 'candy_check/play_store/acknowledgement_failure'
require 'candy_check/play_store/acknowledger'
require 'candy_check/play_store/verifier'

module CandyCheck
  # Module to request and verify a AppStore receipt
  module PlayStore
  end
end