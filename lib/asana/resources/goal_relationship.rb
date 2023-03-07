require_relative 'gen/goal_relationships_base'

module Asana
  module Resources
    class GoalRelationship < GoalRelationshipsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :contribution_weight
      
      attr_reader :resource_subtype

      attr_reader :supported_goal

      attr_reader :owner

      attr_reader :supporting_resource

      attr_reader :supporting_resource

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'goal_relationships'
        end
      end
    end
  end
end
