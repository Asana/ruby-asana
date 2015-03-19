require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/multi_json'

require_relative 'version'

module Asana
  # Internal: Wrapper over Faraday that abstracts authentication, request
  # parsing and common options.
  class HttpClient
    # Internal: The default user agent to use in all requests to the API.
    USER_AGENT = "ruby-asana v#{Asana::VERSION}"

    # Public: Initializes an HttpClient to make requests to the Asana API.
    #
    # authentication       - An Asana::Authentication strategy.
    # adapter              - A Faraday adapter. Defaults to
    #                        Faraday.default_adapter.
    # user_agent           - The user agent. Defaults to "ruby-asana vX.Y.Z".
    # custom_configuration - An optional block that yields the Faraday builder
    #                        object for customization.
    def initialize(authentication:,
                   adapter: Faraday.default_adapter,
                   user_agent: USER_AGENT, &custom_configuration)
      @connection = Faraday.new do |builder|
        authentication.configure(builder)
        builder.headers[:user_agent] = user_agent
        configure_format(builder)
        add_middleware(builder)
        custom_configuration.call(builder) if custom_configuration
        builder.adapter(adapter)
      end
    end

    # Public: Performs a GET request against the API.
    def get(url)
      @connection.get(url)
    end

    private

    def configure_format(builder)
      builder.request :multi_json
      builder.response :multi_json
    end

    def add_middleware(builder)
      builder.use Faraday::Response::RaiseError
      builder.use FaradayMiddleware::FollowRedirects
    end
  end
end
