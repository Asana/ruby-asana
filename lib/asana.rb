# frozen_string_literal: true

require 'asana/compatibility_helper'
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
