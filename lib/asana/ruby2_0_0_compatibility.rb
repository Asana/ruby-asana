def required(name)
  fail(ArgumentError, "#{name} is a required keyword argument")
end
