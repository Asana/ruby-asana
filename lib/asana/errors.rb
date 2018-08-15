module Asana
  # Public: Defines the different errors that the Asana API may throw, which the
  # client code may want to catch.
  module Errors
    # Public: A generic, catch-all API error. It contains the whole response
    # object for debugging purposes.
    #
    # Note: This exception should never be raised when there exists a more
    # specific subclass.
    APIError = Class.new(StandardError) do
      attr_accessor :response

      def to_s
        'An unknown API error ocurred.'
      end
    end

    # Public: A 401 error. Raised when the credentials used are invalid and the
    # user could not be authenticated.
    NotAuthorized = Class.new(APIError) do
      def to_s
        'Valid credentials were not provided with the request, so the API could '\
        'not associate a user with the request.'
      end
    end

    # Public: A 402 error. Raised when the user is trying to access a feature
    # that requires a premium account (Payment Required).
    PremiumOnly = Class.new(APIError) do
      def to_s
        'The endpoint that is being requested is only available to premium '\
        'users.'
      end
    end

    # Public: A 403 error. Raised when the user doesn't have permission to
    # access the requested resource or to perform the requested action on it.
    Forbidden = Class.new(APIError) do
      def to_s
        'The authorization and request syntax was valid but the server is refusing '\
        'to complete the request. This can happen if you try to read or write '\
        'to objects or properties that the user does not have access to.'
      end
    end

    # Public: A 404 error. Raised when the requested resource doesn't exist.
    NotFound = Class.new(APIError) do
      def to_s
        'Either the request method and path supplied do not specify a known '\
        'action in the API, or the object specified by the request does not '\
        'exist.'
      end
    end

    # Public: A 500 error. Raised when there is a problem in the Asana API
    # server. It contains a unique phrase that can be used to identify the
    # problem when contacting developer support.
    ServerError = Class.new(APIError) do
      attr_accessor :phrase

      def initialize(phrase)
        @phrase = phrase
      end

      def to_s
        "There has been an error on Asana's end. Use this unique phrase to "\
        'identify the problem when contacting support: ' + %("#{@phrase}")
      end
    end

    # Public: A 400 error. Raised when the request was malformed or missing some
    # parameters. It contains a list of errors indicating the specific problems.
    InvalidRequest = Class.new(APIError) do
      attr_accessor :errors

      def initialize(errors)
        @errors = errors
      end

      def to_s
        errors.join(', ')
      end
    end

    # Public: A 429 error. Raised when the Asana API enforces rate-limiting on
    # the client to avoid overload. It contains the number of seconds to wait
    # before retrying the operation.
    RateLimitEnforced = Class.new(APIError) do
      attr_accessor :retry_after_seconds

      def initialize(retry_after_seconds)
        @retry_after_seconds = retry_after_seconds
      end

      def to_s
        "Retry your request after #{@retry_after_seconds} seconds."
      end
    end
  end
end
