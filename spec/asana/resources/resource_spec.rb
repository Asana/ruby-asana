require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Resource do
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
      def self.find_by_id(client, id)
        new({ 'gid' => id }, client: client)
      end
    end
  end

  let!(:world_class) do
    defresource 'World'
  end

  it 'auto-vivifies plain properties of the resource' do
    unicorn = unicorn_class.new({ 'name' => 'John' }, client: client)
    expect(unicorn.name).to eq('John')
  end

  it 'wraps hash values into Resources' do
    unicorn = unicorn_class.new({ 'friend' => { 'gid' => "1" } }, client: client)
    expect(unicorn.friend).to be_a(described_class)
    expect(unicorn.friend.gid).to eq("1")
  end

  it 'wraps array values into arrays of Resources' do
    unicorn = unicorn_class.new({ 'friends' => [{ 'gid' => "1" }] },
                                client: client)
    expect(unicorn.friends.first).to be_a(described_class)
    expect(unicorn.friends.first.gid).to eq("1")
  end

  describe '#refresh' do
    describe 'when the class responds to find_by_id' do
      it 'refetches itself' do
        unicorn = unicorn_class.new({ 'gid' => "5" }, client: client)
        expect(unicorn.refresh.gid).to eq("5")
      end
    end
  end
end
