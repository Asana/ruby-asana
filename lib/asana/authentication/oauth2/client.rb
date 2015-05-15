require 'oauth2'

module Asana
  module Authentication
    module OAuth2
      # Public: Deals with the details of obtaining an OAuth2 authorization URL
      # and obtaining access tokens from either authorization codes or refresh
      # tokens.
      class Client
        # Public: Initializes a new client with client credentials associated
        # with a registered Asana API application.
        #
        # client_id     - [String] a client id from the registered application
        # client_secret - [String] a client secret from the registered
        #                 application
        # redirect_uri  - [String] a redirect uri from the registered
        #                 application
        def initialize(client_id: required('client_id'),
                       client_secret: required('client_secret'),
                       redirect_uri: required('redirect_uri'))
          @client = ::OAuth2::Client.new(client_id, client_secret,
                                         site: 'https://app.asana.com',
                                         authorize_url: '/-/oauth_authorize',
                                         token_url: '/-/oauth_token')
          @redirect_uri = redirect_uri
        end

        # Public:
        # Returns the [String] OAuth2 authorize URL.
        def authorize_url
          @client.auth_code.authorize_url(redirect_uri: @redirect_uri)
        end

        # Public: Retrieves a token from an authorization code.
        #
        # Returns the [::OAuth2::AccessToken] token.
        def token_from_auth_code(auth_code)
          @client.auth_code.get_token(auth_code, redirect_uri: @redirect_uri)
        end

        # Public: Retrieves a token from a refresh token.
        #
        # Returns the refreshed [::OAuth2::AccessToken] token.
        def token_from_refresh_token(token)
          ::OAuth2::AccessToken.new(@client, '', refresh_token: token).refresh!
        end
      end
    end
  end
end
