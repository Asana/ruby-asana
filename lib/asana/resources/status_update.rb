require_relative 'gen/status_updates_base'

module Asana
  module Resources
    class StatusUpdate < StatusUpdatesBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :html_text
      
      attr_reader :resource_subtype

      attr_reader :status_type

      attr_reader :text

      attr_reader :title

      attr_reader :author

      attr_reader :created_at

      attr_reader :created_by

      attr_reader :hearted

      attr_reader :hearts

      attr_reader :liked

      attr_reader :likes

      attr_reader :created_at

      attr_reader :modified_at

      attr_reader :num_hearts

      attr_reader :num_likes

      attr_reader :parent

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'status_updates'
        end
      end
    end
  end
end
