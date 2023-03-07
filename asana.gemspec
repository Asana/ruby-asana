# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asana/version'

Gem::Specification.new do |spec|
  spec.name          = 'asana'
  spec.version       = Asana::VERSION
  spec.authors       = ['Txus']
  spec.email         = ['me@txus.io']

  spec.summary       = 'Official Ruby client for the Asana API'
  spec.description   = 'Official Ruby client for the Asana API'
  spec.homepage      = 'https://github.com/asana/ruby-asana'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'faraday-follow_redirects'
  spec.add_dependency 'faraday-multipart'
  spec.add_dependency 'oauth2', '>= 1.4', '< 3'

  spec.add_development_dependency 'appraisal', '~> 2.1', '>= 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
