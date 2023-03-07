require_relative 'gen/memberships_base'

module Asana
  module Resources
    class Membership < MembershipsBase


      attr_reader :gid

      attr_reader :resource_type

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'memberships'
        end
      end
    end
  end
end
