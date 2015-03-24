require_relative 'authentication'
require_relative 'client/configuration'

module Asana
  # Public: A client to interact with the Asana API. It exposes all the
  # available resources of the Asana API in idiomatic Ruby.
  #
  # Examples
  #
  #   # Authentication with an API token
  #   Asana::Client.new do |client|
  #     client.authentication :api_token, '...'
  #   end
  #
  #   # OAuth2 with a plain bearer token (doesn't support auto-refresh)
  #   Asana::Client.new do |client|
  #     client.authentication :oauth2, bearer_token: '...'
  #   end
  #
  #   # OAuth2 with a plain refresh token and client credentials
  #   Asana::Client.new do |client|
  #     client.authentication :oauth2,
  #                           refresh_token: '...',
  #                           client_id: '...',
  #                           client_secret: '...',
  #                           redirect_uri: '...'
  #   end
  #
  #   # OAuth2 with an ::OAuth2::AccessToken object
  #   Asana::Client.new do |client|
  #     client.authentication :oauth2, my_oauth2_access_token_object
  #   end
  #
  #   # Use a custom Faraday network adapter
  #   Asana::Client.new do |client|
  #     client.authentication ...
  #     client.adapter :typhoeus
  #   end
  #
  #   # Use a custom user agent string
  #   Asana::Client.new do |client|
  #     client.authentication ...
  #     client.user_agent '...'
  #   end
  #
  #   # Pass in custom configuration to the Faraday connection
  #   Asana::Client.new do |client|
  #     client.authentication ...
  #     client.configure_faraday { |conn| conn.use MyMiddleware }
  #   end
  #
  class Client
    # Public: Initializes a new client.
    #
    # Yields a {Asana::Client::Configuration} object as a configuration
    # DSL. See {Asana::Client} for usage examples.
    def initialize
      config = Configuration.new.tap { |c| yield c }.to_h
      @http_client =
        HttpClient.new(authentication: config.fetch(:authentication),
                       adapter:        config[:faraday_adapter],
                       user_agent:     config[:user_agent],
                       &config[:faraday_config])
    end
  end
end
