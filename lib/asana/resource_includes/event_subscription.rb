require_relative 'events'

module Asana
  module Resources
    # Public: Mixin to enable a resource with the ability to fetch events about
    # itself.
    module EventSubscription
      # Public: Returns an infinite collection of events on the resource.
      def events(wait: 1, options: {})
        Events.new(resource: gid, client: client, wait: wait, options: options)
      end
    end
  end
end
