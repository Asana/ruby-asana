# frozen_string_literal: true

module Asana
  module CompatibilityHelper
    def required(name)
      raise(ArgumentError, "#{name} is a required keyword argument")
    end

    extend self
  end
end
