require_relative 'resources/resource'
require_relative 'resources/collection'

Dir[File.join(File.dirname(__FILE__), 'resources', '*.rb')]
  .each { |resource| require resource }

module Asana
  # Public: Contains all the resources that the Asana API can return.
  module Resources
  end
end
