require_relative 'authentication'
require_relative 'client/configuration'
require_relative 'resources'

module Asana
  # Public: A client to interact with the Asana API. It exposes all the
  # available resources of the Asana API in idiomatic Ruby.
  #
  # Examples
  #
  #   # Authentication with a personal access token
  #   Asana::Client.new do |client|
  #     client.authentication :access_token, '...'
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
    # Internal: Proxies Resource classes to implement a fluent API on the Client
    # instances.
    class ResourceProxy
      def initialize(client: required('client'), resource: required('resource'))
        @client   = client
        @resource = resource
      end

      def method_missing(m, *args, &block)
        @resource.public_send(m, *([@client] + args), &block)
      end

      def respond_to_missing?(m, *)
        @resource.respond_to?(m)
      end
    end

    # Public: Initializes a new client.
    #
    # Yields a {Asana::Client::Configuration} object as a configuration
    # DSL. See {Asana::Client} for usage examples.
    def initialize
      config = Configuration.new.tap { |c| yield c }.to_h
      @http_client =
        HttpClient.new(authentication:            config.fetch(:authentication),
                       adapter:                   config[:faraday_adapter],
                       user_agent:                config[:user_agent],
                       debug_mode:                config[:debug_mode],
                       log_asana_change_warnings: config[:log_asana_change_warnings],
                       default_headers:           config[:default_headers],
                       &config[:faraday_configuration])
    end

    # Public: Performs a GET request against an arbitrary Asana URL. Allows for
    # the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def get(url, *args)
      @http_client.get(url, *args)
    end

    # Public: Performs a POST request against an arbitrary Asana URL. Allows for
    # the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def post(url, *args)
      @http_client.post(url, *args)
    end

    # Public: Performs a PUT request against an arbitrary Asana URL. Allows for
    # the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def put(url, *args)
      @http_client.put(url, *args)
    end

    # Public: Performs a DELETE request against an arbitrary Asana URL. Allows
    # for the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def delete(url, *args)
      @http_client.delete(url, *args)
    end

    # Public: Exposes queries for all top-evel endpoints.
    #
    # E.g. #users will query /users and return a
    # Asana::Resources::Collection<User>.
    Resources::Registry.resources.each do |resource_class|
      define_method(resource_class.plural_name) do
        ResourceProxy.new(client: @http_client,
                          resource: resource_class)
      end
    end
  end
end
