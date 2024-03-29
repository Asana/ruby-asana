### WARNING: This file is auto-generated by our OpenAPI spec. Do not
### edit it manually.

require_relative '../../resource_includes/response_helper'

module Asana
  module Resources
    class WebhooksBase < Resource

      def self.inherited(base)
        Registry.register(base)
      end

      class << self
        # Establish a webhook
        #

        # options - [Hash] the request I/O options
        # > opt_fields - [list[str]]  Defines fields to return. Some requests return *compact* representations of objects in order to conserve resources and complete the request more efficiently. Other times requests return more information than you may need. This option allows you to list the exact set of fields that the API should be sure to return for the objects. The field names should be provided as paths, described below. The id of included objects will always be returned, regardless of the field options.
        # > opt_pretty - [bool]  Provides “pretty” output. Provides the response in a “pretty” format. In the case of JSON this means doing proper line breaking and indentation to make it readable. This will take extra time and increase the response size so it is advisable only to use this during debugging.
        # data - [Hash] the attributes to POST
        def create_webhook(client, options: {}, **data)
          path = "/webhooks"
          Webhook.new(parse(client.post(path, body: data, options: options)).first, client: client)
        end

        # Delete a webhook
        #
        # webhook_gid - [str]  (required) Globally unique identifier for the webhook.
        # options - [Hash] the request I/O options
        # > opt_fields - [list[str]]  Defines fields to return. Some requests return *compact* representations of objects in order to conserve resources and complete the request more efficiently. Other times requests return more information than you may need. This option allows you to list the exact set of fields that the API should be sure to return for the objects. The field names should be provided as paths, described below. The id of included objects will always be returned, regardless of the field options.
        # > opt_pretty - [bool]  Provides “pretty” output. Provides the response in a “pretty” format. In the case of JSON this means doing proper line breaking and indentation to make it readable. This will take extra time and increase the response size so it is advisable only to use this during debugging.
        def delete_webhook(client, webhook_gid: required("webhook_gid"), options: {})
          path = "/webhooks/{webhook_gid}"
          path["{webhook_gid}"] = webhook_gid
          parse(client.delete(path, options: options)).first
        end

        # Get a webhook
        #
        # webhook_gid - [str]  (required) Globally unique identifier for the webhook.
        # options - [Hash] the request I/O options
        # > opt_fields - [list[str]]  Defines fields to return. Some requests return *compact* representations of objects in order to conserve resources and complete the request more efficiently. Other times requests return more information than you may need. This option allows you to list the exact set of fields that the API should be sure to return for the objects. The field names should be provided as paths, described below. The id of included objects will always be returned, regardless of the field options.
        # > opt_pretty - [bool]  Provides “pretty” output. Provides the response in a “pretty” format. In the case of JSON this means doing proper line breaking and indentation to make it readable. This will take extra time and increase the response size so it is advisable only to use this during debugging.
        def get_webhook(client, webhook_gid: required("webhook_gid"), options: {})
          path = "/webhooks/{webhook_gid}"
          path["{webhook_gid}"] = webhook_gid
          Webhook.new(parse(client.get(path, options: options)).first, client: client)
        end

        # Get multiple webhooks
        #

        # workspace - [str]  (required) The workspace to query for webhooks in.
        # resource - [str]  Only return webhooks for the given resource.
        # options - [Hash] the request I/O options
        # > offset - [str]  Offset token. An offset to the next page returned by the API. A pagination request will return an offset token, which can be used as an input parameter to the next request. If an offset is not passed in, the API will return the first page of results. 'Note: You can only pass in an offset that was returned to you via a previously paginated request.'
        # > limit - [int]  Results per page. The number of objects to return per page. The value must be between 1 and 100.
        # > opt_fields - [list[str]]  Defines fields to return. Some requests return *compact* representations of objects in order to conserve resources and complete the request more efficiently. Other times requests return more information than you may need. This option allows you to list the exact set of fields that the API should be sure to return for the objects. The field names should be provided as paths, described below. The id of included objects will always be returned, regardless of the field options.
        # > opt_pretty - [bool]  Provides “pretty” output. Provides the response in a “pretty” format. In the case of JSON this means doing proper line breaking and indentation to make it readable. This will take extra time and increase the response size so it is advisable only to use this during debugging.
        def get_webhooks(client, workspace: nil, resource: nil, options: {})
          path = "/webhooks"
          params = { workspace: workspace, resource: resource }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get(path, params: params, options: options)), type: Webhook, client: client)
        end

        # Update a webhook
        #
        # webhook_gid - [str]  (required) Globally unique identifier for the webhook.
        # options - [Hash] the request I/O options
        # > opt_fields - [list[str]]  Defines fields to return. Some requests return *compact* representations of objects in order to conserve resources and complete the request more efficiently. Other times requests return more information than you may need. This option allows you to list the exact set of fields that the API should be sure to return for the objects. The field names should be provided as paths, described below. The id of included objects will always be returned, regardless of the field options.
        # > opt_pretty - [bool]  Provides “pretty” output. Provides the response in a “pretty” format. In the case of JSON this means doing proper line breaking and indentation to make it readable. This will take extra time and increase the response size so it is advisable only to use this during debugging.
        # data - [Hash] the attributes to PUT
        def update_webhook(client, webhook_gid: required("webhook_gid"), options: {}, **data)
          path = "/webhooks/{webhook_gid}"
          path["{webhook_gid}"] = webhook_gid
          Webhook.new(parse(client.put(path, body: data, options: options)).first, client: client)
        end

      end
    end
  end
end
