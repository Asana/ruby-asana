module Asana
  # Internal: Module-mangling utilities.
  module Util
    module_function

    # Public: Returns the enclosing module of a module.
    #
    # mod - [Module] the module enclosed by another.
    #
    # Returns the enclosing module.
    #
    # Examples
    #
    #   Asana::Util.namespace(Asana::Util)
    #   # => Asana
    #
    def namespace(mod)
      ::Object.const_get(mod.name.split('::').tap(&:pop).join('::'))
    end

    # Public: Underscores a CamelCase string.
    #
    # str - [#to_s] the string to underscore.
    #
    # Returns the underscored version of the String.
    #
    # Examples
    #
    #   Asana::Util.underscore('FooBar')
    #   # => 'foo_bar'
    #
    def underscore(str)
      str.to_s.split('::').last.gsub(/([^\^])([A-Z])/, '\1_\2').downcase
    end
  end
end
