require 'bundler'
Bundler.require
require 'asana'

id, secret = ENV['ASANA_CLIENT_ID'], ENV['ASANA_CLIENT_SECRET']
unless id && secret
  abort "Run this program with the env vars ASANA_CLIENT_ID and ASANA_CLIENT_SECRET.\n"  \
    "Refer to https://asana.com/developers/documentation/getting-started/authentication "\
    "to get your credentials." \
    "The redirect URI for your application should be \"urn:ietf:wg:oauth:2.0:oob\"."
end

access_token = Asana::Authentication::OAuth2.offline_flow(client_id: id,
                                                          client_secret: secret)
client = Asana::Client.new do |c|
  c.authentication :oauth2, access_token
end

puts "My Workspaces:"
client.workspaces.find_all.each do |workspace|
  puts "\t* #{workspace.name} - tags:"
  client.tags.find_by_workspace(workspace: workspace.id).each do |tag|
    puts "\t\t- #{tag.name}"
  end
end
