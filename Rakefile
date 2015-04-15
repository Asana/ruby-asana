require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new do |t|
  t.stats_options = ['--list-undoc']
end

desc 'Generates a test resource from a YAML using the resource template.'
task :codegen do
  `node spec/support/codegen.js`
end

task default: [:codegen, :spec, :rubocop, :yard]
