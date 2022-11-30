require 'bundler'
Bundler.require
require 'asana'

access_token = ENV['ASANA_ACCESS_TOKEN']
unless access_token
  abort "Run this program with the env var ASANA_ACCESS_TOKEN.\n"  \
    "Go to http://app.asana.com/-/account_api to create a personal access token."
end

client = Asana::Client.new do |c|
  c.authentication :access_token, access_token
end

puts "My Workspaces:"
client.workspaces.get_workspaces.each do |workspace|
  puts "\t* #{workspace.name} - tags:"
  client.tags.get_tags_for_workspace(workspace: workspace.id).each do |tag|
    puts "\t\t- #{tag.name}"
  end
end
