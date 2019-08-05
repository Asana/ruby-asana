module Asana
  class Client
    # Internal: Represents a configuration DSL for an Asana::Client.
    #
    # Examples
    #
    #   config = Configuration.new
    #   config.authentication :access_token, 'personal_access_token'
    #   config.adapter :typhoeus
    #   config.configure_faraday { |conn| conn.use MyMiddleware }
    #   config.to_h
    #   # => { authentication: #<Authentication::TokenAuthentication>,
    #          faraday_adapter: :typhoeus,
    #          faraday_configuration: #<Proc> }
    #
    class Configuration
      # Public: Initializes an empty configuration object.
      def initialize
        @configuration = {
            :log_asana_change_warnings => true
        }
      end

      # Public: Sets an authentication strategy.
      #
      # type  - [:oauth2, :api_token] the kind of authentication strategy to use
      # value - [::OAuth2::AccessToken, String, Hash] the configuration for the
      #         chosen authentication strategy.
      #
      # Returns nothing.
      #
      # Raises ArgumentError if the arguments are invalid.
      def authentication(type, value)
        auth = case type
               when :oauth2 then oauth2(value)
               when :access_token then from_bearer_token(value)
               else error "unsupported authentication type #{type}"
               end
        @configuration[:authentication] = auth
      end

      # Public: Sets a custom network adapter for Faraday.
      #
      # adapter - [Symbol, Proc] the adapter.
      #
      # Returns nothing.
      def faraday_adapter(adapter)
        @configuration[:faraday_adapter] = adapter
      end

      # Public: Sets a custom configuration block for the Faraday connection.
      #
      # config - [Proc] the configuration block.
      #
      # Returns nothing.
      def configure_faraday(&config)
        @configuration[:faraday_configuration] = config
      end

      # Public: Configures the client in debug mode, which will print verbose
      # information on STDERR.
      #
      # Returns nothing.
      def debug_mode
        @configuration[:debug_mode] = true
      end

      # Public: Configures the client to log Asana-Change warnings on STDERR.
      #
      # Returns nothing.
      def log_asana_change_warnings(value)
        @configuration[:log_asana_change_warnings] = !!value
      end

      # Public: Configures the client to always send the given headers
      #
      # Returns nothing.
      def default_headers(value)
        @configuration[:default_headers] = value
      end

      # Public:
      # Returns the configuration [Hash].
      def to_h
        @configuration
      end

      private

      # Internal: Configures an OAuth2 authentication strategy from either an
      # OAuth2 access token object, or a plain refresh token, or a plain bearer
      # token.
      #
      # value - [::OAuth::AccessToken, String] the value to configure the
      #         strategy from.
      #
      # Returns [Asana::Authentication::OAuth2::AccessTokenAuthentication,
      #          Asana::Authentication::OAuth2::BearerTokenAuthentication]
      #         the OAuth2 authentication strategy.
      #
      # Raises ArgumentError if the OAuth2 configuration arguments are invalid.
      #
      # rubocop:disable Metrics/MethodLength
      def oauth2(value)
        case value
        when ::OAuth2::AccessToken
          from_access_token(value)
        when ->(v) { v.is_a?(Hash) && v[:refresh_token] }
          from_refresh_token(value)
        when ->(v) { v.is_a?(Hash) && v[:bearer_token] }
          from_bearer_token(value[:bearer_token])
        else
          error 'Invalid OAuth2 configuration: pass in either an ' \
            '::OAuth2::AccessToken object of your own or a hash ' \
            'containing :refresh_token or :bearer_token.'
        end
      end

      # Internal: Configures an OAuth2 AccessTokenAuthentication strategy.
      #
      # access_token - [::OAuth2::AccessToken] the OAuth2 access token object
      #
      # Returns a [Authentication::OAuth2::AccessTokenAuthentication] strategy.
      def from_access_token(access_token)
        Authentication::OAuth2::AccessTokenAuthentication
          .new(access_token)
      end

      # Internal: Configures an OAuth2 AccessTokenAuthentication strategy.
      #
      # hash - The configuration hash:
      #        :refresh_token - [String] the OAuth2 refresh token
      #        :client_id     - [String] the OAuth2 client id
      #        :client_secret - [String] the OAuth2 client secret
      #        :redirect_uri  - [String] the OAuth2 redirect URI
      #
      # Returns a [Authentication::OAuth2::AccessTokenAuthentication] strategy.
      def from_refresh_token(hash)
        refresh_token, client_id, client_secret, redirect_uri =
          requiring(hash, :refresh_token, :client_id,
                    :client_secret, :redirect_uri)

        Authentication::OAuth2::AccessTokenAuthentication
          .from_refresh_token(refresh_token,
                              client_id: client_id,
                              client_secret: client_secret,
                              redirect_uri: redirect_uri)
      end

      # Internal: Configures an OAuth2 BearerTokenAuthentication strategy.
      #
      # bearer_token - [String] the plain OAuth2 bearer token
      #
      # Returns a [Authentication::OAuth2::BearerTokenAuthentication] strategy.
      def from_bearer_token(bearer_token)
        Authentication::OAuth2::BearerTokenAuthentication
          .new(bearer_token)
      end

      def requiring(hash, *keys)
        missing_keys = keys.select { |k| !hash.key?(k) }
        missing_keys.any? && error("Missing keys: #{missing_keys.join(', ')}")
        keys.map { |k| hash[k] }
      end

      def error(msg)
        raise ArgumentError, msg
      end
    end
  end
end
