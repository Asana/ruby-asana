# Internal: Helpeer to define resource classes in tests.
module ResourcesHelper
  # Public: Defines a new resource.
  #
  # resource_name - [String] the unqualified, capitalized resource name,
  #                 e.g. 'Unicorn'.
  # body          - [Proc] a block configuring the resource with its DSL.
  #
  # Returns the class object.
  def defresource(resource_name, &body)
    name = "Asana::Resources::#{resource_name}"
    Class.new(Asana::Resources::Resource) do
      define_singleton_method(:==) { |other| self.name == other.name }
      define_singleton_method(:name) { name }
      define_singleton_method(:to_s) { name }
      define_singleton_method(:inspect) { name }
      instance_eval(&body)
    end
  end
end
