require_relative 'collection'

module Asana
  module Resources
    # Internal: Represents a query to the Asana API.
    #
    # Examples
    #
    #   query = Query.new(client: http_client,
    #                     resource: Asana::Resources::Unicorn
    #                     scope: '/worlds/3')
    #   query.all # => #<Asana::Resources::Collection<Unicorn> ...>
    #   query.find(1) # => #<Asana::Resources::Unicorn ...>
    #
    class Query
      # Public: Initializes a new Query object.
      #
      # client   - [Asana::HttpClient] an HTTP client to perform the
      #                  requests.
      # resource - [Class] A Resource class to wrap the responses in.
      # scope    - [String] An optional scope (URL path) to scope the query in.
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

      # Internal: Proxies method calls to the collection returnd by #all. It is
      # especially useful to delegate Enumerable methods to it, transparently
      # triggering the API request.
      #
      # Raises a NoMethodError if the collection doesn't respond to the method.
      def method_missing(m, *args, &block)
        return super unless respond_to_missing?(m, *args)
        all.public_send(m, *args, &block)
      end

      # Internal: Guard for the method_missing proxy. Checks if the delegate
      # instance actually responds to the proxied method.
      #
      # Returns true if the instance has the method, false otherwise.
      def respond_to_missing?(m, *)
        Asana::Resources::Collection.method_defined?(m)
      end

      private

      # Internal: Wraps elements in a collection.
      #
      # elements - [Array] the elements.
      #
      # Returns an [Asana::Resources::Collectin] with the elements.
      def collection(elements)
        Collection.new(client: @client,
                       resource_class: @resource_class,
                       scope: @scope,
                       elements: elements)
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
