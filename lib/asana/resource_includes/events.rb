require_relative 'event'

module Asana
  module Resources
    # Public: An infinite collection of events.
    #
    # Since they are infinite, if you want to filter or do other collection
    # operations without blocking indefinitely you should call #lazy on them to
    # turn them into a lazy collection.
    #
    # Examples:
    #
    #   # Subscribes to an event stream and blocks indefinitely, printing
    #   # information of every event as it comes in.
    #   events = Events.new(resource: 'someresourceID', client: client)
    #   events.each do |event|
    #     puts [event.type, event.action]
    #   end
    #
    #   # Lazily filters events as they come in and prints them.
    #   events = Events.new(resource: 'someresourceID', client: client)
    #   events.lazy.select { |e| e.type == 'task' }.each do |event|
    #     puts [event.type, event.action]
    #   end
    #
    class Events
      include Enumerable

      # Public: Initializes a new Events instance, subscribed to a resource ID.
      #
      # resource - [String] a resource ID. Can be a task id or a workspace id.
      # client   - [Asana::Client] a client to perform the requests.
      # wait     - [Integer] the number of seconds to wait between each poll.
      # options  - [Hash] the request I/O options
      def initialize(resource: required('resource'),
                     client: required('client'),
                     wait: 1, options: {})
        @resource  = resource
        @client    = client
        @events    = []
        @wait      = wait
        @options   = options
        @sync      = nil
        @last_poll = nil
      end

      # Public: Iterates indefinitely over all events happening to a particular
      # resource from the @sync timestamp or from now if it is nil.
      def each(&block)
        if block
          loop do
            poll if @events.empty?
            event = @events.shift
            yield event if event
          end
        else
          to_enum
        end
      end

      private

      # Internal: Polls and fetches all events that have occurred since the sync
      # token was created. Updates the sync token as it comes back from the
      # response.
      #
      # If we polled less than @wait seconds ago, we don't do anything.
      #
      # Notes:
      #
      # On the first request, the sync token is not passed (because it is
      # nil). The response will be the same as for an expired sync token, and
      # will include a new valid sync token.
      #
      # If the sync token is too old (which may happen from time to time)
      # the API will return a `412 Precondition Failed` error, and include
      # a fresh `sync` token in the response.
      def poll
        rate_limiting do
          body = @client.get('/events',
                             params: params,
                             options: @options).body
          @sync = body['sync']
          @events += body.fetch('data', []).map do |event_data|
            Event.new(event_data, client: @client)
          end
        end
      end

      # Internal: Returns the formatted params for the poll request.
      def params
        { resource: @resource, sync: @sync }.reject { |_, v| v.nil? }
      end

      # Internal: Executes a block if at least @wait seconds have passed since
      # @last_poll.
      def rate_limiting
        return if @last_poll && Time.now - @last_poll <= @wait
        yield.tap { @last_poll = Time.now }
      end
    end
  end
end
