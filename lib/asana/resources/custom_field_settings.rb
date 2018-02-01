### WARNING: This file is auto-generated by the asana-api-meta repo. Do not
### edit it manually.

module Asana
  module Resources
    # Custom fields are attached to a particular project with the Custom
    # Field Settings resource. This resource both represents the many-to-many join
    # of the Custom Field and Project as well as stores information that is relevant to that
    # particular pairing; for instance, the `is_important` property determines
    # some possible application-specific handling of that custom field (see below)
    class CustomFieldSetting < Resource


      attr_reader :id

      attr_reader :created_at

      attr_reader :is_important

      attr_reader :project

      attr_reader :custom_field

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'custom_field_settings'
        end

        # Returns a list of all of the custom fields settings on a project, in compact form. Note that, as in all queries to collections which return compact representation, `opt_fields` and `opt_expand` can be used to include more data than is returned in the compact representation. See the getting started guide on [input/output options](/developers/documentation/getting-started/input-output-options) for more information.
        #
        # project - [Id] The ID of the project for which to list custom field settings
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_by_project(client, project: required("project"), per_page: 20, options: {})
          params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/projects/#{project}/custom_field_settings", params: params, options: options)), type: Resource, client: client)
        end
      end

    end
  end
end