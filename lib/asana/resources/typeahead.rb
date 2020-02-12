require_relative 'gen/typeahead_base'

module Asana
  module Resources
    class Typeahead < TypeaheadBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :name

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'typeaheads'
        end
      end
    end
  end
end
