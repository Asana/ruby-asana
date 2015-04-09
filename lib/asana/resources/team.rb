require_relative 'resource'

module Asana
  module Resources
    # Public: An Asana team.
    class Team < Resource
      path '/teams', top_level: false
    end
  end
end
