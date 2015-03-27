require_relative 'resource'

module Asana
  module Resources
    # Public: An Asana user.
    class User < Resource
      path '/users'
      contains_many :workspaces
    end
  end
end
