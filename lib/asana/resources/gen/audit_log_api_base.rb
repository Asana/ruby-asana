### WARNING: This file is auto-generated by our OpenAPI spec. Do not
### edit it manually.

require_relative '../../resource_includes/response_helper'

module Asana
  module Resources
    class AuditLogAPIBase < Resource

      def self.inherited(base)
        Registry.register(base)
      end

      class << self
        # Get audit log events
        #
        # workspace_gid - [str]  (required) Globally unique identifier for the workspace or organization.
        # start_at - [datetime]  Filter to events created after this time (inclusive).
        # end_at - [datetime]  Filter to events created before this time (exclusive).
        # event_type - [str]  Filter to events of this type. Refer to the [Supported AuditLogEvents](/docs/supported-auditlogevents) for a full list of values.
        # actor_type - [str]  Filter to events with an actor of this type. This only needs to be included if querying for actor types without an ID. If `actor_gid` is included, this should be excluded.
        # actor_gid - [str]  Filter to events triggered by the actor with this ID.
        # resource_gid - [str]  Filter to events with this resource ID.
        # options - [Hash] the request I/O options
        # > offset - [str]  Offset token. An offset to the next page returned by the API. A pagination request will return an offset token, which can be used as an input parameter to the next request. If an offset is not passed in, the API will return the first page of results. 'Note: You can only pass in an offset that was returned to you via a previously paginated request.'
        # > limit - [int]  Results per page. The number of objects to return per page. The value must be between 1 and 100.
        def get_audit_log_events(client, workspace_gid: required("workspace_gid"), start_at: nil, end_at: nil, event_type: nil, actor_type: nil, actor_gid: nil, resource_gid: nil, options: {})
          path = "/workspaces/{workspace_gid}/audit_log_events"
          path["{workspace_gid}"] = workspace_gid
          params = { start_at: start_at, end_at: end_at, event_type: event_type, actor_type: actor_type, actor_gid: actor_gid, resource_gid: resource_gid }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get(path, params: params, options: options)), type: Resource, client: client)
        end

      end
    end
  end
end
