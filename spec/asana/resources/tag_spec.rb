
require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Tag do
  let(:api) { StubAPI.new }
  let(:client) do
    Asana::Client.new do |c|
      c.authentication :access_token, "foo"
      c.faraday_adapter api.to_proc
    end
  end

  include ResourcesHelper

  it 'contains backwards compatable method' do
    tag = Asana::Resources::Tag.new({:gid => 15}, **{:client => client})

    api.on(:get, "/tags/#{tag.gid}/tasks") do |response|
      response.body = { data: [{foo: "bar"}] }
    end

    res = tag.get_tasks_with_tag

    expect(res != nil)
  end
end
