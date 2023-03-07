require_relative 'gen/project_briefs_base'

module Asana
  module Resources
    class ProjectBrief < ProjectBriefsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :html_text
      
      attr_reader :title

      attr_reader :permalink_url

      attr_reader :project

      attr_reader :text

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'project_briefs'
        end
      end
    end
  end
end
