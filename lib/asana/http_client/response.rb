module Asana
  class HttpClient
    # Internal: Represents a response from the Asana API.
    class Response
      # Public:
      # Returns a [Faraday::Env] object for debugging.
      attr_reader :faraday_env
      # Public:
      # Returns the [Integer] status code of the response.
      attr_reader :status
      # Public:
      # Returns the [Hash] representing the parsed JSON body.
      attr_reader :body
      # Public:
      # Returns the [Hash] of attribute headers.
      attr_reader :headers

      # Public: Wraps a Faraday response.
      #
      # faraday_response - [Faraday::Response] the Faraday response to wrap.
      def initialize(faraday_response)
        @faraday_env = faraday_response.env
        @status      = faraday_env.status
        @body        = faraday_env.body
        @headers     = faraday_response.headers
      end

      # Public:
      # Returns a [String] representation of the response.
      def to_s
        "#<Asana::HttpClient::Response status=#{@status} body=#{@body}>"
      end
      alias inspect to_s
    end
  end
end
