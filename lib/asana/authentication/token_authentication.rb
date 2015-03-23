module Asana
  module Authentication
    # Public: Represents an API token authentication mechanism.
    class TokenAuthentication
      def initialize(token)
        @token = token
      end

      # Public: Configures a Faraday connection injecting its token as
      # basic auth.
      #
      # builder - [Faraday::Connection] the Faraday connection instance.
      #
      # Returns nothing.
      def configure(connection)
        connection.basic_auth(@token, '')
      end
    end
  end
end
