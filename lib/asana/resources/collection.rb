module Asana
  module Resources
    # Public: Represents a collection of Asana resources.
    class Collection
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
      def initialize(client, resource_class, vals = [])
        @client         = client
        @resource_klass = resource_class
        @elements       = vals.map do |v|
          v.is_a?(Resource) ? v : @resource_klass.new(client, v)
        end
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
        "#<#{self.class.name}<#{resource_class}> #{elements}>"
      end
      alias_method :inspect, :to_s

      protected

      attr_reader :resource_class, :elements
    end
  end
end
