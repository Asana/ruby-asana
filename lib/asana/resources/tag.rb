require_relative 'resource'

module Asana
  module Resources
    # Public: An Asana tag.
    class Tag < Resource
      path '/tags'
      contains_many :users, as: :followers
      contains_one :workspace
      has_many :tasks
    end
  end
end
