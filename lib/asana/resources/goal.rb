require_relative 'gen/goals_base'

module Asana
  module Resources
    class Goal < GoalsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :due_on
      
      attr_reader :html_notes

      attr_reader :is_workspace_level

      attr_reader :liked

      attr_reader :name

      attr_reader :notes

      attr_reader :start_on

      attr_reader :status

      attr_reader :current_status_update

      attr_reader :followers

      attr_reader :likes
      
      attr_reader :metric
      
      attr_reader :num_likes

      attr_reader :owner

      attr_reader :team

      attr_reader :time_period

      attr_reader :workspace

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'goals'
        end
      end
    end
  end
end
