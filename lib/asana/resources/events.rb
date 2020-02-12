require_relative 'gen/events_base'

module Asana
  module Resources
    class EventResponse < EventsBase


      attr_reader :user

      attr_reader :resource

      attr_reader :type

      attr_reader :action

      attr_reader :parent

      attr_reader :created_at

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'event_responses'
        end
      end
    end
  end
end
