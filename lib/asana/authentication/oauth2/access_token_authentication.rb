# frozen_string_literal: true

module Asana
  module Authentication
    module OAuth2
      # Public: A mechanism to authenticate with an OAuth2 access token (a
      # bearer token and a refresh token) or just a refresh token.
      class AccessTokenAuthentication
        # Public: Builds an AccessTokenAuthentication from a refresh token and
        # client credentials, by refreshing into a new one.
        #
        # refresh_token - [String] a refresh token
        # client_id     - [String] the client id of the registered Asana API
        #                 Application.
        # client_secret - [String] the client secret of the registered Asana API
        #                 Application.
        # redirect_uri  - [String] the redirect uri of the registered Asana API
        #                 Application.
        #
        # Returns an [AccessTokenAuthentication] instance with a refreshed
        # access token.
        def self.from_refresh_token(refresh_token,
                                    client_id: CompatibilityHelper.required('client_id'),
                                    client_secret: CompatibilityHelper.required('client_secret'),
                                    redirect_uri: CompatibilityHelper.required('redirect_uri'))
          client = Client.new(client_id: client_id,
                              client_secret: client_secret,
                              redirect_uri: redirect_uri)
          new(client.token_from_refresh_token(refresh_token))
        end

        # Public: Initializes a new AccessTokenAuthentication.
        #
        # access_token - [::OAuth2::AccessToken] An ::OAuth2::AccessToken
        #                object.
        def initialize(access_token)
          @token = access_token
        end

        # Public: Configures a Faraday connection injecting a bearer token,
        # auto-refreshing it when needed.
        #
        # connection - [Faraday::Connection] the Faraday connection instance.
        #
        # Returns nothing.
        def configure(connection)
          @token = @token.refresh! if @token.expired?

          connection.request :authorization, 'Bearer', @token.token
        end
      end
    end
  end
end
