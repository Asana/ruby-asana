require_relative 'resource'
require 'set'

module Asana
  module Resources
    # Internal: Global registry of Resource subclasses. It provides lookup from
    # singular and plural names to the actual class objects.
    #
    # Examples
    #
    #   class Unicorn < Asana::Resources::Resource
    #     path '/unicorns'
    #   end
    #
    #   Registry.lookup(:unicorn) # => Unicorn
    #   Registry.lookup_many(:unicorns) # => Unicorn
    #
    module Registry
      class << self
        # Public: Registers a new resource class.
        #
        # resource_klass - [Class] the resource class.
        #
        # Returns nothing.
        def register(resource_klass)
          resources << resource_klass
        end

        # Public: Looks up a resource class by its singular name.
        #
        # singular_name - [#to_s] the name of the resource, e.g :unicorn.
        #
        # Returns the resource class or {Asana::Resources::Resource}.
        def lookup(singular_name)
          resources.detect do |klass|
            klass.singular_name.to_s == singular_name.to_s
          end || Resource
        end

        # Public: Looks up a resource class by its plural name.
        #
        # plural_name - [#to_s] the plural name of the resource, e.g :unicorns.
        #
        # Returns the resource class or {Asana::Resources::Resource}.
        def lookup_many(plural_name)
          resources.detect do |klass|
            klass.plural_name.to_s == plural_name.to_s
          end || Resource
        end

        # Internal: A set of Resource classes.
        #
        # Returns the Set, defaulting to the empty set.
        #
        # Note: this object is a mutable singleton, so it should not be accessed
        # from multiple threads.
        def resources
          @resources ||= Set.new
        end
      end
    end
  end
end
