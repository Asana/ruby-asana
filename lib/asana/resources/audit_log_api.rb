require_relative 'gen/audit_log_api_base'

module Asana
  module Resources
    class AuditLogAPI < AuditLogAPIBase


      attr_reader :gid

      attr_reader :actor

      attr_reader :context
      
      attr_reader :api_authentication_method

      attr_reader :client_ip_address
      
      attr_reader :context_type

      attr_reader :oauth_app_name

      attr_reader :user_agent

      attr_reader :created_at

      attr_reader :details

      attr_reader :event_category

      attr_reader :event_type

      attr_reader :resource

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'audit_log_apis'
        end
      end
    end
  end
end
