require_relative 'oauth2/bearer_token_authentication'
require_relative 'oauth2/access_token_authentication'
require_relative 'oauth2/client'

module Asana
  module Authentication
    # Public: Deals with OAuth2 authentication. Contains a function to get an
    # access token throught a browserless authentication flow, needed for some
    # applications such as CLI applications.
    module OAuth2
      module_function

      # Public: Retrieves an access token through an offline authentication
      # flow. If your application can receive HTTP requests, you might want to
      # opt for a browser-based flow and use the omniauth-asana gem instead.
      #
      # Your registered application's redirect_uri should be exactly
      # "urn:ietf:wg:oauth:2.0:oob".
      #
      # client_id     - [String] the client id of the registered Asana API
      #                 application.
      # client_secret - [String] the client secret of the registered Asana API
      #                 application.
      #
      # Returns an ::OAuth2::AccessToken object.
      #
      # Note: This function reads from STDIN and writes to STDOUT. It is meant
      # to be used only within the context of a CLI application.
      def offline_flow(client_id: required('client_id'),
                       client_secret: required('client_secret'))
        client = Client.new(client_id: client_id,
                            client_secret: client_secret,
                            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
        STDOUT.puts '1. Go to the following URL to authorize the ' \
          " application: #{client.authorize_url}"
        STDOUT.puts '2. Paste the authorization code here: '
        auth_code = STDIN.gets.chomp
        client.token_from_auth_code(auth_code)
      end
    end
  end
end
