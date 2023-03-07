require_relative 'gen/time_periods_base'

module Asana
  module Resources
    class TimePeriod < TimePeriodsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :display_name
      
      attr_reader :end_on

      attr_reader :parent

      attr_reader :period

      attr_reader :start_on

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'time_periods'
        end
      end
    end
  end
end
