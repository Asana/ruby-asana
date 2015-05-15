require 'asana/ruby2_0_0_compatibility'
require 'asana/authentication'
require 'asana/resources'
require 'asana/client'
require 'asana/errors'
require 'asana/http_client'
require 'asana/version'

# Public: Top-level namespace of the Asana API Ruby client.
module Asana
  include Asana::Resources
end
