require_relative '../util'
require_relative 'registry'
require_relative 'collection'

module Asana
  module Resources
    # Internal: Minimal DSL to configure Resource classes, included in
    # Asana::Resources::Resource.
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
    module DSL
      # Internal: The base URI of the resource relativo to the API root.
      attr_reader :base_uri

      # Public: Defines the base URI of the resource relative to the API root.
      #
      # uri - [String] the relative path of the resource, e.g. '/users'
      #
      # Returns nothing.
      def path(uri) # rubocop:disable Style/TrivialAccessors
        @base_uri = uri
      end

      # Public: Declares a contained object.
      #
      # Defines a reader method with the resource name (or the provided alias),
      # that wraps the object data in a specific resource class matching the
      # contained object name if found, or the generic Resource otherwise.
      #
      # resource_name - [Symbol] the contained object name.
      # as            - [Symbol] an alias for the object name. Defaults to nil.
      #
      # Returns nothing.
      #
      # Examples
      #
      #   class Unicorn < Asana::Resources::Resource
      #     contains_one :horn
      #   end
      #
      #   unicorn = Unicorn.new(client, { 'id' => 10,
      #                                   'horn' => { 'diamonds' => true }})
      #   unicorn.horn
      #   # => #<Asana::Resources::Resource ...>
      #   unicorn.horn.diamonds
      #   # => true
      #
      # rubocop:disable Metrics/MethodLength
      def contains_one(resource_name, as: nil)
        name = (as || resource_name).to_s
        define_method(name) do
          field = :"@#{name}"
          if instance_variable_defined?(field)
            instance_variable_get(field)
          else
            value = if to_h.key?(name)
                      Registry.lookup(resource_name).new(client, to_h[name])
                    end
            instance_variable_set(field, value)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Public: Declares a contained collection.
      #
      # Defines a reader method with the plural resource name (or the provided
      # alias), that wraps the collection in a Collection class parameterized by
      # the resources_name Resource subclass, or just Resource otherwise.
      #
      # resources_name - [Symbol] the collection name.
      # as             - [Symbol] an alias for the collection name. Defaults to
      #                  nil.
      #
      # Returns nothing.
      #
      # Examples
      #
      #   class Unicorn < Asana::Resources::Resource
      #     contains_many :unicorns, as: :friends
      #   end
      #
      #   unicorn = Unicorn.new(client, { 'id' => 10,
      #                                   'friends' => [{ 'id' => 11 }]})
      #   unicorn.friends
      #   # => #<Asana::Resources::Collection<Unicorn>...>
      #   unicorn.friends.first
      #   # => #<Unicorn ...>
      #
      # rubocop:disable Metrics/MethodLength
      def contains_many(resources_name, as: nil)
        name = (as || resources_name).to_s
        define_method(name) do
          field = :"@#{name}"
          if instance_variable_defined?(field)
            instance_variable_get(field)
          else
            resource_class = Registry.lookup_many(resources_name)
            coll = Resources::Collection.new(client,
                                             resource_class,
                                             to_h.fetch(name, []))
            instance_variable_set(field, coll)
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Public: Declares a has_many relationship.
      #
      # Defines a reader method with the plural resource name (or the provided
      # alias), that wraps the collection in a Collection class parameterized by
      # the resources_name Resource subclass.
      #
      # The reader method will perform a network request to fetch the collection.
      #
      # resources_name - [Symbol] the collection name.
      # as             - [Symbol] an alias for the collection name. Defaults to
      #                  nil.
      #
      # Returns nothing.
      #
      # Examples
      #
      #   # /unicorns/10/friends
      #
      #   class Unicorn < Asana::Resources::Resource
      #     has_many :unicorns, as: :friends
      #   end
      #
      #   unicorn = Unicorn.new(client, { 'id' => 10 })
      #   unicorn.friends
      #   # fetches from /unicorns/10/friends
      #   # => #<Asana::Resources::Collection<Unicorn>...>
      #   unicorn.friends.first
      #   # => #<Unicorn ...>
      #
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Style/PredicateName
      def has_many(resources_name, as: nil)
        name = (as || resources_name).to_s
        define_method(name) do
          field = :"@#{name}"
          if instance_variable_defined?(field)
            instance_variable_get(field)
          else
            resource_class = Registry.lookup_many(resources_name)
            query = Query.new(client: client,
                              resource: resource_class,
                              scope: uri)
            instance_variable_set(field, query.all)
          end
        end
      end
      # rubocop:enable Style/PredicateName
      # rubocop:enable Metrics/MethodLength

      # Internal: Parses the base URI to figure out the plural name of the
      # resource.
      #
      # Returns the plural name of the resource as a Symbol.
      def plural_name
        @base_uri.scan(%r{^\/([^\/]+)}).first.first.to_sym
      end

      # Internal:
      # Returns the singular name of the resource as a Symbol.
      def singular_name
        Util.underscore(name).to_sym
      end
    end
  end
end
