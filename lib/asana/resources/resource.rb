require_relative 'dsl'
require_relative 'registry'

module Asana
  module Resources
    # Public: Represents an abstract Asana resource. Subclass it to define your
    # own.
    #
    # Examples
    #
    #   class Unicorn < Asana::Resources::Resource
    #     path '/unicorns'
    #
    #     contains_one :horn
    #     contains_one :unicorn, as: :mother
    #     contains_one :treasure
    #     contains_many :unicorns, as: :friends
    #     contains_many :favorite_foods
    #   end
    #
    class Resource
      # Internal: Subclassing hook. It registers itself in
      # Asana::Resources::Registry.
      def self.inherited(klass)
        Registry.register(klass)
      end

      extend Resources::DSL

      # Internal: Initializes a new resource.
      #
      # client - [Asana::HttpClient] a client to refresh itself and ask for
      #          other resources.
      # hash   - [Hash] the data of the resource.
      def initialize(client, hash = {})
        @client = client
        @data   = hash
      end

      # Internal: Proxies method calls to the data, wrapping it accordingly and
      # caching the result by defining a real reader method.
      #
      # Returns the value for the requested property.
      #
      # Raises a NoMethodError if the property doesn't exist.
      def method_missing(m, *args)
        super unless respond_to_missing?(m, *args)
        cache(m, wrapped(@data[m.to_s]))
      end

      # Internal: Guard for the method_missing proxy. Checks if the resource
      # actually has a specific piece of data at all.
      #
      # Returns true if the resource has th property, false otherwise.
      def respond_to_missing?(m, *)
        @data.key?(m.to_s)
      end

      # Public:
      # Returns the raw Hash representation of the data.
      def to_h
        @data
      end

      # Public: Decides whether the resource is refreshable or not, depending on
      # if it has a path to fetch itself from.
      #
      # Returns true if it's refreshable, false otherwise.
      def refreshable?
        self.class.base_uri && respond_to?(:id)
      end

      # Public: Refreshes the resource, fetching itself from the Asana API.
      #
      # Returns the refreshed resource, or self if it doesn't have enough data
      # to refresh.
      #
      # Raises StandardError if it can't understand the response body.
      def refresh
        return self unless refreshable?
        response = client.get(self.class.base_uri + "/#{id}")
        self.class.new(client,
                       response.body['data'] ||
                         fail("Unexpected response body: #{response.body}"))
      end

      # Public: Compares to another resource for equality, based on its data and
      # class.
      #
      # other - [Asana::Resources::Resource] the other resource.
      def ==(other)
        self.class == other.class && to_h == other.to_h
      end

      # Public:
      # Returns a String representation of the resource.
      def to_s
        "#<#{self.class.name} #{to_h}>"
      end
      alias_method :inspect, :to_s

      private

      attr_reader :client

      # Internal: Caches a property and a value by defining a reader method for
      # it.
      #
      # property - [#to_s] the property
      # value    - [Object] the corresponding value
      #
      # Returns the value.
      def cache(property, value)
        field = :"@#{property}"
        instance_variable_set(field, value)
        define_singleton_method(property) { instance_variable_get(field) }
        value
      end

      # Internal: Wraps a value in a more useful class if possible, namely a
      # Resource or a Collection.
      #
      # Returns the wrapped value or the plain value if it couldn't be wrapped.
      def wrapped(value)
        case value
        when Hash then Resource.new(client, value)
        when Array then Collection.new(client, Resource, value)
        else value
        end
      end
    end
  end
end
