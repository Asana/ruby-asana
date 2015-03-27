require_relative 'collection'

module Asana
  module Resources
    # Internal: Represents a query to the Asana API.
    #
    # Examples
    #
    #   query = Query.new(http_client, Asana::Resources::Unicorn)
    #   query.all # => #<Asana::Resources::Collection<Unicorn> ...>
    #   query.find(1) # => #<Asana::Resources::Unicorn ...>
    #
    class Query
      # Public: Initializes a new Query object.
      #
      # http_client    - [Asana::HttpClient] an HTTP client to perform the
      #                  requests.
      # resource_class - [Class] A Resource class to wrap the responses in.
      def initialize(client:, resource:, scope: nil)
        @client         = client
        @resource_class = resource
        @base_uri       = resource.base_uri
        @scope          = scope || ''
      end

      # Public: Queries all elements scoped to the resource class.
      #
      # Returns an [Asana::Resources::Collection<resource_class>] with the
      # elements.
      #
      # Raises an Asana::Errors::APIError if anything went wrong.
      def all
        collection(get)
      end

      # Public: Queries a specific element of a resource class by its id.
      #
      # Returns an instance of [resource_class].
      #
      # Raises an Asana::Errors::APIError if anything went wrong.
      def find(id)
        resource(get("/#{id}"))
      end

      private

      # Internal: Wraps elements in a collection.
      #
      # elements - [Array] the elements.
      #
      # Returns an [Asana::Resources::Collectin] with the elements.
      def collection(elements)
        Collection.new(@client, @resource_class, elements)
      end

      # Internal: Wraps data in a resource object.
      #
      # data - [Hash] the plain data that came with the response.
      #
      # Returns an instance of the resource_class.
      def resource(data)
        @resource_class.new(@client, data)
      end

      # Internal: Helper to perform GET requests against the API.
      #
      # path - [String] the path relative to the @base_uri.
      #
      # Returns a [Hash] with the response body's data.
      def get(path = '')
        @client.get(@scope + @base_uri + path).body['data']
      end
    end
  end
end
