module Asana
  # Internal: Authentication strategies for the Asana API.
  module Authentication
    # Internal: Represents an API token authentication mechanism.
    class TokenAuthentication
      def initialize(token)
        @token = token
      end

      # Public: Configures a Faraday connection builder injecting its token as
      # basic auth.
      def configure(builder)
        builder.basic_auth(@token, '')
      end
    end
  end
end
