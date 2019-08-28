module Asana
  module Authentication
    module OAuth2
      # Public: A mechanism to authenticate with an OAuth2 bearer token obtained
      # somewhere, for instance through omniauth-asana.
      #
      # Note: This authentication mechanism doesn't support token refreshing. If
      # you'd like refreshing and you have a refresh token as well as a bearer
      # token, you can generate a proper access token with
      # {AccessTokenAuthentication.from_refresh_token}.
      class BearerTokenAuthentication
        # Public: Initializes a new BearerTokenAuthentication with a plain
        # bearer token.
        #
        # bearer_token - [String] a plain bearer token.
        def initialize(bearer_token)
          @token = bearer_token
        end

        # Public: Configures a Faraday connection injecting its token as an
        # OAuth2 bearer token.
        #
        # connection - [Faraday::Connection] the Faraday connection instance.
        #
        # Returns nothing.
        def configure(connection)
          connection.authorization :Bearer, @token
          connection.request :oauth2, token_type: 'bearer'
        end
      end
    end
  end
end
