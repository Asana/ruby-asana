module Asana
  module Resources
    module ResponseHelper
      def body(response)
        response.body.fetch('data') do
          fail("Unexpected response body: #{response.body}")
        end
      end
    end
  end
end
