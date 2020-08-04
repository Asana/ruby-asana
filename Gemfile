source 'https://rubygems.org'

# Specify your gem's dependencies in asana.gemspec
gemspec

group :tools do
  # Currently we need to pin the version of Rubocop, due to an incompatibility
  # with rubocop-rspec.  However, this also solves the problem that Rubocop
  # routinely adds new checks which can cause our build to "break" even when no
  # changes have been made. In this situation it's better to intentionally
  # upgrade Rubocop and fix issues at that time.
  gem 'rubocop', '~> 0.52.1'
  gem 'rubocop-rspec', '~> 1.22.2'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-yard'

  gem 'yard'
  gem 'yard-tomdoc'

  gem 'byebug'

  gem 'simplecov', require: false

  gem "rack-protection", "1.5.5"
end
