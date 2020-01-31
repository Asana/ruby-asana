require_relative 'gen/workspace_memberships_base'

module Asana
  module Resources
    class WorkspaceMembership < WorkspaceMembershipsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :user

      attr_reader :workspace

      attr_reader :user_task_list

      attr_reader :is_admin

      attr_reader :is_active

      attr_reader :is_guest

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'workspace_memberships'
        end
      end
    end
  end
end
