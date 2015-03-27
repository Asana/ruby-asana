require_relative 'resource'

module Asana
  module Resources
    # Public: An Asana workspace.
    class Workspace < Resource
      path '/workspaces'
      has_many :users
    end
  end
end
