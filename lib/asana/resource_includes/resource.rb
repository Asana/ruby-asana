require_relative 'registry'
require_relative 'response_helper'

module Asana
  module Resources
    # Public: The base resource class which provides some sugar over common
    # resource functionality.
    class Resource
      include ResponseHelper
      extend ResponseHelper

      def self.inherited(base)
        Registry.register(base)
      end

      def initialize(data, client: required('client'))
        @_client = client
        @_data   = data
        data.each do |k, v|
          instance_variable_set(:"@#{k}", v) if respond_to?(k)
        end
      end

      # If it has findById, it implements #refresh
      def refresh
        raise "#{self.class.name} does not respond to #find_by_id" unless \
          self.class.respond_to?(:find_by_id)
        self.class.find_by_id(client, gid)
      end

      # Internal: Proxies method calls to the data, wrapping it accordingly and
      # caching the result by defining a real reader method.
      #
      # Returns the value for the requested property.
      #
      # Raises a NoMethodError if the property doesn't exist.
      def method_missing(m, *args)
        super unless respond_to_missing?(m, *args)
        cache(m, wrapped(to_h[m.to_s]))
      end

      # Internal: Guard for the method_missing proxy. Checks if the resource
      # actually has a specific piece of data at all.
      #
      # Returns true if the resource has the property, false otherwise.
      def respond_to_missing?(m, *)
        to_h.key?(m.to_s)
      end

      # Public:
      # Returns the raw Hash representation of the data.
      def to_h
        @_data
      end

      def to_s
        attrs = to_h.map { |k, _| "#{k}: #{public_send(k).inspect}" }.join(', ')
        "#<Asana::#{self.class.name.split('::').last} #{attrs}>"
      end
      alias inspect to_s

      private

      # Internal: The Asana::Client instance.
      def client
        @_client
      end

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
        when Hash then Resource.new(value, client: client)
        when Array then value.map(&method(:wrapped))
        else value
        end
      end

      def refresh_with(data)
        self.class.new(data, client: @_client)
      end
    end
  end
end
