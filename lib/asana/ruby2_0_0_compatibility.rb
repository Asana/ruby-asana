# frozen_string_literal: true

def required(name)
  raise(ArgumentError, "#{name} is a required keyword argument")
end
