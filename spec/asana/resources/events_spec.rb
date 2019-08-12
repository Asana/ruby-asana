require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Events do
  let(:api) { StubAPI.new }
  let(:authentication) do
    Asana::Authentication::TokenAuthentication.new('token')
  end
  let(:client) do
    Asana::HttpClient.new(authentication: authentication, adapter: api.adapter)
  end

  include ResourcesHelper

  let!(:unicorn_class) do
    defresource 'Unicorn' do
      include Asana::Resources::EventSubscription
      attr_reader :gid
    end
  end

  let(:unicorn) do
    unicorn_class.new({ gid: "1" }, client: client)
  end

  let(:first_batch) do
    [
      { type: 'unicorn', action: 'born' },
      { type: 'unicorn', action: 'first_words' }
    ]
  end

  let(:second_batch) { [] }

  let(:third_batch) do
    [{ type: 'unicorn', action: 'learned_to_fly' }]
  end

  it 'is an infinite collection of events on a resource' do
    api.on(:get, '/events', resource: "1") do |response|
      response.body = { sync: 'firstsynctoken',
                        data: first_batch }
    end

    api.on(:get, '/events', resource: "1", sync: 'firstsynctoken') do |response|
      response.body = { sync: 'secondsynctoken',
                        data: second_batch }
    end

    api.on(:get, '/events', resource: "1", sync: 'secondsynctoken') do |response|
      response.body = { sync: 'thirdsynctoken',
                        data: third_batch }
    end

    events = described_class.new(resource: unicorn.gid,
                                 client: client,
                                 wait: 0).take(3)
    expect(events.all? { |e| e.is_a?(Asana::Resources::Event) }).to eq(true)
    expect(events.all? { |e| e.type == 'unicorn' }).to eq(true)
    expect(events.map(&:action)).to eq(%w(born first_words learned_to_fly))
  end

  it 'allows to fetch events about oneself with EventSubscription' do
    api.on(:get, '/events', resource: 1) do |response|
      response.body = { sync: 'firstsynctoken',
                        data: first_batch }
    end

    expect(unicorn.events.first.action).to eq('born')
  end
end
