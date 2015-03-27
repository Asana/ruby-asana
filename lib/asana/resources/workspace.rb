require_relative 'resource'

module Asana
  module Resources
    # Public: An Asana workspace.
    class Workspace < Resource
      path '/workspaces'
    end
  end
end
