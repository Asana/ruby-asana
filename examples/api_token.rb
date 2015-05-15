require 'bundler'
Bundler.require
require 'asana'

api_token = ENV['ASANA_API_TOKEN']
unless api_token
  abort "Run this program with the env var ASANA_API_TOKEN.\n"  \
    "Go to http://app.asana.com/-/account_api to see your API token."
end

client = Asana::Client.new do |c|
  c.authentication :api_token, api_token
end

puts "My Workspaces:"
client.workspaces.find_all.each do |workspace|
  puts "\t* #{workspace.name} - tags:"
  client.tags.find_by_workspace(workspace: workspace.id).each do |tag|
    puts "\t\t- #{tag.name}"
  end
end
