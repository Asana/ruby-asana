# frozen_string_literal: true

require_relative 'resource_includes/resource'
require_relative 'resource_includes/collection'

Dir[File.join(File.dirname(__FILE__), 'resource_includes', '*.rb')].sort.each { |resource| require resource }

Dir[File.join(File.dirname(__FILE__), 'resources', '*.rb')].sort.each { |resource| require resource }

module Asana
  # Public: Contains all the resources that the Asana API can return.
  module Resources
  end
end
