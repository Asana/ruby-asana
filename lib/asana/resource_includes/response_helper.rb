module Asana
  module Resources
    # Internal: A helper to make response body parsing easier.
    module ResponseHelper
      def parse(response)
        data = response.body.fetch('data') do
          raise("Unexpected response body: #{response.body}")
        end
        extra = response.body.reject { |k, _| k == 'data' }
        [data, extra]
      end
    end
  end
end
