require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/multi_json'

require_relative 'http_client/error_handling'
require_relative 'http_client/environment_info'
require_relative 'http_client/response'

module Asana
  # Internal: Wrapper over Faraday that abstracts authentication, request
  # parsing and common options.
  class HttpClient
    # Internal: The API base URI.
    BASE_URI = 'https://app.asana.com/api/1.0'.freeze

    # Public: Initializes an HttpClient to make requests to the Asana API.
    #
    # authentication - [Asana::Authentication] An authentication strategy.
    # adapter        - [Symbol, Proc] A Faraday adapter, eiter a Symbol for
    #                  registered adapters or a Proc taking a builder for a
    #                  custom one. Defaults to Faraday.default_adapter.
    # user_agent     - [String] The user agent. Defaults to "ruby-asana vX.Y.Z".
    # config         - [Proc] An optional block that yields the Faraday builder
    #                  object for customization.
    def initialize(authentication: required('authentication'),
                   adapter: nil,
                   user_agent: nil,
                   debug_mode: false,
                   &config)
      @authentication   = authentication
      @adapter          = adapter || Faraday.default_adapter
      @environment_info = EnvironmentInfo.new(user_agent)
      @debug_mode       = debug_mode
      @config           = config
    end

    # Public: Performs a GET request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Asana API
    #                URL, e.g "/users/me".
    # params       - [Hash] the request parameters
    # options      - [Hash] the request I/O options
    #
    # Returns an [Asana::HttpClient::Response] if everything went well.
    # Raises [Asana::Errors::APIError] if anything went wrong.
    def get(resource_uri, params: {}, options: {})
      opts = options.reduce({}) do |acc, (k, v)|
        acc.tap do |hash|
          hash[:"opt_#{k}"] = v.is_a?(Array) ? v.join(',') : v
        end
      end
      perform_request(:get, resource_uri, params.merge(opts))
    end

    # Public: Performs a PUT request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Asana API
    #                URL, e.g "/users/me".
    # body         - [Hash] the body to PUT.
    # options      - [Hash] the request I/O options
    #
    # Returns an [Asana::HttpClient::Response] if everything went well.
    # Raises [Asana::Errors::APIError] if anything went wrong.
    def put(resource_uri, body: {}, options: {})
      params = { data: body }.merge(options.empty? ? {} : { options: options })
      perform_request(:put, resource_uri, params)
    end

    # Public: Performs a POST request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Asana API
    #                URL, e.g "/tags".
    # body         - [Hash] the body to POST.
    # upload       - [Faraday::UploadIO] an upload object to post as multipart.
    #                Defaults to nil.
    # options      - [Hash] the request I/O options
    #
    # Returns an [Asana::HttpClient::Response] if everything went well.
    # Raises [Asana::Errors::APIError] if anything went wrong.
    def post(resource_uri, body: {}, upload: nil, options: {})
      params = { data: body }.merge(options.empty? ? {} : { options: options })
      if upload
        perform_request(:post, resource_uri, params.merge(file: upload)) do |c|
          c.request :multipart
        end
      else
        perform_request(:post, resource_uri, params)
      end
    end

    # Public: Performs a DELETE request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Asana API
    #                URL, e.g "/tags".
    #
    # Returns an [Asana::HttpClient::Response] if everything went well.
    # Raises [Asana::Errors::APIError] if anything went wrong.
    def delete(resource_uri)
      perform_request(:delete, resource_uri)
    end

    private

    def connection(&request_config)
      Faraday.new do |builder|
        @authentication.configure(builder)
        @environment_info.configure(builder)
        yield builder if request_config
        configure_format(builder)
        add_middleware(builder)
        @config.call(builder) if @config
        use_adapter(builder, @adapter)
      end
    end

    def perform_request(method, resource_uri, body = {}, &request_config)
      handling_errors do
        url = BASE_URI + resource_uri
        log_request(method, url, body) if @debug_mode
        Response.new(connection(&request_config).public_send(method, url, body))
      end
    end

    def configure_format(builder)
      builder.request :multi_json
      builder.response :multi_json
    end

    def add_middleware(builder)
      builder.use Faraday::Response::RaiseError
      builder.use FaradayMiddleware::FollowRedirects
    end

    def use_adapter(builder, adapter)
      case adapter
      when Symbol
        builder.adapter(adapter)
      when Proc
        adapter.call(builder)
      end
    end

    def handling_errors(&request)
      ErrorHandling.handle(&request)
    end

    def log_request(method, url, body)
      STDERR.puts format('[%s] %s %s (%s)',
                         self.class,
                         method.to_s.upcase,
                         url,
                         body.inspect)
    end
  end
end
