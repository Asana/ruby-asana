module Asana
  module Resources
    # Public: Mixin to enable a resource with the ability to fetch events about
    # itself.
    module EventSubscription
      # Public: Returns an infinite collection of events on the resource.
      def events
        Events.new(resource: id, client: client)
      end
    end
  end
end
