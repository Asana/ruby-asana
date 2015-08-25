# -*- coding: utf-8 -*-
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

workspace = client.workspaces.find_all.first
task = client.tasks.find_all(assignee: "me", workspace: workspace.id).first
unless task
  task = client.tasks.create(workspace: workspace.id, name: "Hello world!", assignee: "me")
end

Thread.abort_on_exception = true

Thread.new do
  puts "Listening for 'changed' events on #{task} in one thread..."
  task.events(wait: 2).lazy.select { |event| event.action == 'changed' }.each do |event|
    puts "#{event.user.name} changed #{event.resource}"
  end
end

Thread.new do
  puts "Listening for non-'changed' events on #{task} in another thread..."
  task.events(wait: 1).lazy.reject { |event| event.action == 'changed' }.each do |event|
    puts "'#{event.action}' event: #{event}"
  end
end

sleep
