require_relative 'response_helper'

module Asana
  module Resources
    # Public: Represents a paginated collection of Asana resources.
    class Collection
      include Enumerable
      include ResponseHelper

      # Public: Initializes a collection representing a page of resources of a
      # given type.
      #
      # (elements, extra) - [Array] an (String, Hash) tuple coming from the
      #                     response parser.
      # type              - [Class] the type of resource that the collection
      #                     contains. Defaults to the generic Resource.
      # client            - [Asana::Client] the client to perform requests.
      def initialize((elements, extra), type: Resource, client:)
        @elements  = elements.map { |elem| type.new(elem, client: client) }
        @type      = type
        @next_page = extra['next_page']
        @client    = client
      end

      # Public: Returns a new Asana::Resources::Collection with the next page or
      # nil if there are no more pages.
      def next_page
        return nil unless @next_page
        response = parse(@client.get(@next_page['path']))
        self.class.new(response, type: @type, client: @client)
      end

      # Public: Iterates over the elements of the collection.
      def each(&block)
        @elements.each(&block)
      end

      # Public: Returns the size of the collection.
      def size
        @elements.size
      end
      alias_method :length, :size

      # Public: Returns a String representation of the collection.
      def to_s
        "#<Asana::Collection<#{@type}> " \
          "[#{@elements.map(&:inspect).join(', ')}]>"
      end

      alias_method :inspect, :to_s
    end
  end
end
