
require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Task do
  let(:api) { StubAPI.new }
  let(:client) do
    Asana::Client.new do |c|
      c.authentication :access_token, "foo"
      c.faraday_adapter api.to_proc
    end
  end

  include ResourcesHelper

  it 'contains backwards compatable method' do
    id = 15
    checks = 0

    api.on(:get, "/projects/#{id}/tasks") do |response|
      response.body = { data: [] }
      checks = checks + 1
    end

    client.tasks.find_by_project({:project => id})
    client.tasks.find_by_project({:projectId => id})
    client.tasks.find_by_project({:project => nil, :projectId => id})
    client.tasks.find_by_project({:project => id, :projectId => nil})

    expect(checks == 4)
  end
end
