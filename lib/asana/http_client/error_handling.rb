require 'multi_json'

require_relative '../errors'

module Asana
  class HttpClient
    # Internal: Handles errors from the API and re-raises them as proper
    # exceptions.
    module ErrorHandling
      include Errors

      module_function

      MAX_TIMEOUTS = 5

      # Public: Perform a request handling any API errors correspondingly.
      #
      # request - [Proc] a block that will execute the request.
      #
      # Returns a [Faraday::Response] object.
      #
      # Raises [Asana::Errors::InvalidRequest] for invalid requests.
      # Raises [Asana::Errors::NotAuthorized] for unauthorized requests.
      # Raises [Asana::Errors::Forbidden] for forbidden requests.
      # Raises [Asana::Errors::NotFound] when a resource can't be found.
      # Raises [Asana::Errors::RateLimitEnforced] when the API is throttling.
      # Raises [Asana::Errors::ServerError] when there's a server problem.
      # Raises [Asana::Errors::APIError] when the API returns an unknown error.
      #
      # rubocop:disable all
      def handle(num_timeouts=0, &request)
        request.call
      rescue Faraday::ClientError => e
        raise e unless e.response
        case e.response[:status]
          when 400 then raise invalid_request(e.response)
          when 401 then raise not_authorized(e.response)
          when 402 then raise payment_required(e.response)
          when 403 then raise forbidden(e.response)
          when 404 then raise not_found(e.response)
          when 412 then recover_response(e.response)
          when 429 then raise rate_limit_enforced(e.response)
          when 500 then raise server_error(e.response)
          else raise api_error(e.response)
        end
      rescue Net::ReadTimeout => e
        if num_timeouts < MAX_TIMEOUTS
          handle(num_timeouts + 1, &request)
        else
          raise e
        end
      end
      # rubocop:enable all

      # Internal: Returns an InvalidRequest exception including a list of
      # errors.
      def invalid_request(response)
        errors = body(response).fetch('errors', []).map { |e| e['message'] }
        InvalidRequest.new(errors).tap do |exception|
          exception.response = response
        end
      end

      # Internal: Returns a NotAuthorized exception.
      def not_authorized(response)
        NotAuthorized.new.tap { |exception| exception.response = response }
      end

      # Internal: Returns a PremiumOnly exception.
      def payment_required(response)
        PremiumOnly.new.tap { |exception| exception.response = response }
      end

      # Internal: Returns a Forbidden exception.
      def forbidden(response)
        Forbidden.new.tap { |exception| exception.response = response }
      end

      # Internal: Returns a NotFound exception.
      def not_found(response)
        NotFound.new.tap { |exception| exception.response = response }
      end

      # Internal: Returns a RateLimitEnforced exception with a retry after
      # field.
      def rate_limit_enforced(response)
        retry_after_seconds = response[:headers]['Retry-After']
        RateLimitEnforced.new(retry_after_seconds).tap do |exception|
          exception.response = response
        end
      end

      # Internal: Returns a ServerError exception with a unique phrase.
      def server_error(response)
        phrase = body(response).fetch('errors', []).first['phrase']
        ServerError.new(phrase).tap do |exception|
          exception.response = response
        end
      end

      # Internal: Returns an APIError exception.
      def api_error(response)
        APIError.new.tap { |exception| exception.response = response }
      end

      # Internal: Parser a response body from JSON.
      def body(response)
        MultiJson.load(response[:body])
      end

      def recover_response(response)
        r = response.dup.tap { |res| res[:body] = body(response) }
        Response.new(OpenStruct.new(env: OpenStruct.new(r)))
      end
    end
  end
end
