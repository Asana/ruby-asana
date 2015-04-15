module Asana
  module Resources
    # Internal: A helper to make response body parsing easier.
    module ResponseHelper
      def body(response)
        response.body.fetch('data') do
          fail("Unexpected response body: #{response.body}")
        end
      end
    end
  end
end
