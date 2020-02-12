require_relative 'gen/team_memberships_base'

module Asana
  module Resources
    class TeamMembership < TeamMembershipsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :user

      attr_reader :team

      attr_reader :is_guest

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'team_memberships'
        end
      end
    end
  end
end
