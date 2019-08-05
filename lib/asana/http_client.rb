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
                   log_asana_change_warnings: true,
                   default_headers: nil,
                   &config)
      @authentication             = authentication
      @adapter                    = adapter || Faraday.default_adapter
      @environment_info           = EnvironmentInfo.new(user_agent)
      @debug_mode                 = debug_mode
      @log_asana_change_warnings  = log_asana_change_warnings
      @default_headers            = default_headers
      @config                     = config
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
      perform_request(:get, resource_uri, params.merge(opts), options[:headers])
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
      opts = options.reduce({}) do |acc, (k, v)|
        acc.tap do |hash|
          hash[:"opt_#{k}"] = v.is_a?(Array) ? v.join(',') : v
        end
      end
      options.merge(opts)
      params = { data: body }.merge(options.empty? ? {} : { options: options })
      perform_request(:put, resource_uri, params, options[:headers])
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
      opts = options.reduce({}) do |acc, (k, v)|
        acc.tap do |hash|
          hash[:"opt_#{k}"] = v.is_a?(Array) ? v.join(',') : v
        end
      end
      options.merge(opts)
      params = { data: body }.merge(options.empty? ? {} : { options: options })
      if upload
        perform_request(:post, resource_uri, params.merge(file: upload), options[:headers]) do |c|
          c.request :multipart
        end
      else
        perform_request(:post, resource_uri, params, options[:headers])
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

    def perform_request(method, resource_uri, body = {}, headers = {}, &request_config)
      handling_errors do
        url = BASE_URI + resource_uri
        headers = (@default_headers || {}).merge(headers || {})
        log_request(method, url, body) if @debug_mode
        result = Response.new(connection(&request_config).public_send(method, url, body, headers))
        log_asana_change_headers(headers, result.headers) if @log_asana_change_warnings
        result
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

    def log_asana_change_headers(request_headers, response_headers)
      change_header_key = nil

      response_headers.each_key do |key|
        if key.downcase == 'asana-change'
            change_header_key = key
        end
      end

      if change_header_key != nil
        accounted_for_flags = Array.new

        if request_headers == nil
          request_headers = {}
        end
        # Grab the request's asana-enable flags
        request_headers.each_key do |req_header|
          if req_header.downcase == 'asana-enable'
            request_headers[req_header].split(',').each do |flag|
              accounted_for_flags.push(flag)
            end
          elsif req_header.downcase == 'asana-disable'
            request_headers[req_header].split(',').each do |flag|
              accounted_for_flags.push(flag)
            end
          end
        end

        changes = response_headers[change_header_key].split(',')

        changes.each do |unsplit_change|
          change = unsplit_change.split(';')

          name = nil
          info = nil
          affected = nil

          change.each do |unsplit_field|
            field = unsplit_field.split('=')

            field[0].strip!
            field[1].strip!
            if field[0] == 'name'
                name = field[1]
            elsif field[0] == 'info'
                info = field[1]
            elsif field[0] == 'affected'
                affected = field[1]
            end

            # Only show the error if the flag was not in the request's asana-enable header
            if !(accounted_for_flags.include? name) && (affected == 'true')
              message1 = 'This request is affected by the "%s"' +
              ' deprecation. Please visit this url for more info: %s'
              message2 = 'Adding "%s" to your "Asana-Enable" or ' +
              '"Asana-Disable" header will opt in/out to this deprecation ' +
              'and suppress this warning.'

              STDERR.puts format(message1, name, info)
              STDERR.puts format(message2, name)
            end
          end
        end
      end
    end
  end
end


