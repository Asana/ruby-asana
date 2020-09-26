require_relative 'gen/batch_api_base'

module Asana
  module Resources
    class BatchAPI < BatchAPIBase

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'batch_apis'
        end
      end
    end
  end
end
