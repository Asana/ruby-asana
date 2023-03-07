# frozen_string_literal: true

require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Tag do
  let(:api) { StubAPI.new }
  let(:client) do
    Asana::Client.new do |c|
      c.authentication :access_token, 'foo'
      c.faraday_adapter api.to_proc
    end
  end

  include ResourcesHelper

  it 'contains backwards compatable method' do
    tag = described_class.new({ gid: 15 }, client: client)

    api.on(:get, "/tags/#{tag.gid}/tasks") do |response|
      response.body = { data: [{ foo: 'bar' }] }
    end

    res = tag.get_tasks_with_tag

    expect(res).not_to be_nil
  end
end
