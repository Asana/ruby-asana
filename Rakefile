require 'bundler/setup'
require 'bundler/gem_tasks'
require 'appraisal'
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
  # TODO: I believe this is obsolete and can be removed
  `node spec/support/codegen.js`
end

namespace :bump do
  def read_version
    File.readlines('./lib/asana/version.rb')
        .detect { |l| l =~ /VERSION/ }
        .scan(/VERSION = '([^']+)/).flatten.first.split('.')
        .map { |n| Integer(n) }
  end

  # rubocop:disable Metrics/MethodLength
  def write_version(major, minor, patch)
    str = <<-EOS
#:nodoc:
module Asana
  # Public: Version of the gem.
  VERSION = '#{major}.#{minor}.#{patch}'
end
EOS
    File.open('./lib/asana/version.rb', 'w') do |f|
      f.write str
    end

    new_version = "#{major}.#{minor}.#{patch}"
    system('git add lib/asana/version.rb')
    system(%(git commit -m "Bumped to #{new_version}" && ) +
           %(git tag -a v#{new_version} -m "Version #{new_version}"))
    puts "\nRun git push --tags to release."
  end

  desc 'Bumps a patch version'
  task :patch do
    major, minor, patch = read_version
    write_version major, minor, patch + 1
  end

  desc 'Bumps a minor version'
  task :minor do
    major, minor, = read_version
    write_version major, minor + 1, 0
  end

  desc 'Bumps a major version'
  task :major do
    major, = read_version
    write_version major + 1, 0, 0
  end
end

desc 'Default: run the unit tests.'
task default: [:all, :rubocop, :yard]


desc 'Test the plugin under all supported Rails versions.'
task :all do |_t|
  if ENV['TRAVIS']
    # require 'json'
    # puts JSON.pretty_generate(ENV.to_hash)
    if ENV['BUNDLE_GEMFILE'] =~ /gemfiles/
      appraisal_name = ENV['BUNDLE_GEMFILE'].scan(/faraday\_(.*)\.gemfile/).flatten.first
      command_prefix = "appraisal faraday-#{appraisal_name}"
      exec("#{command_prefix} bundle install && #{command_prefix} bundle exec rspec")
    else
      exec(' bundle exec appraisal install && bundle exec rake appraisal spec')
    end
  else
    exec('bundle exec appraisal install && bundle exec rake appraisal spec')
  end
end
