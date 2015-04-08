module Asana
  module Resources
    # Public: Represents a collection of Asana resources.
    class Collection
      include Enumerable

      # Internal: Initializes a new collection containing a specific resource
      # class.
      #
      # client         - [Asana::HttpClient] a client to be able to refresh,
      #                  fetch other elements, etc.
      # resource_class - [Class] the kind of resource this collection will
      #                  hold. Yes, we are reinventing half-assed, ad-hoc
      #                  parametric polymorphism.
      # elements       - [Array] the elements it'll contain. They will be
      #                  automatically wrapped in the proper resource class if
      #                  needed.
      def initialize(client:,
                     resource_class:,
                     scope: nil,
                     elements: [])
        @client         = client
        @resource_class = resource_class
        @elements       = elements.map do |e|
          e.is_a?(Resource) ? e : @resource_class.new(client, e)
        end
        @scope = (scope || '') + "/#{resource_class.plural_name}" unless
          resource_class == Resource
      end

      # Public: Iterates over the elements.
      def each(&block)
        if block
          @elements.each(&block)
        else
          @elements.each
        end
      end

      # Public: Posts a new resource of the kind @resource_class to the API,
      # scoped to the current collection.
      #
      # data - [Hash] the new element data.
      #
      # Returns an instance of @resource_class.
      def create(data)
        ensure_known_resource_class!
        @resource_class.create(client: @client, data: data, uri: @scope)
      end

      # Public: Compares this collection by its resource_class and elements to
      # another one for equality.
      #
      # other - [Asanas::Resources::Collection] the other collection
      #
      # Returns true if they're equal or false otherwise.
      def ==(other)
        self.class == other.class &&
          resource_class == other.resource_class &&
          elements == other.elements
      end

      # Public:
      # Returns a String representation of the collection.
      def to_s
        resource_kind = resource_class.name.split('::').last
        "#<Asana::Collection<#{resource_kind}> #{elements}>"
      end
      alias_method :inspect, :to_s

      protected

      attr_reader :resource_class, :elements

      private

      def ensure_known_resource_class!
        fail 'You cannot operate on generic Resource instances. We cannot ' \
          'know which API resources they reflect.' unless @scope
      end
    end
  end
end
