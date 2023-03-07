require_relative 'gen/project_templates_base'

module Asana
  module Resources
    class ProjectTemplate < ProjectTemplatesBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :color
      
      attr_reader :description

      attr_reader :html_description

      attr_reader :name

      attr_reader :owner

      attr_reader :public

      attr_reader :requested_dates

      attr_reader :team

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'project_templates'
        end
      end
    end
  end
end
