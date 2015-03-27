require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Query do
  let(:api) { StubAPI.new }
  let(:auth) { Asana::Authentication::TokenAuthentication.new('foo') }
  let(:client) do
    Asana::HttpClient.new(authentication: auth, adapter: api.adapter)
  end

  let(:query) { described_class.new(client, unicorn_class) }

  let(:john) { unicorn_class.new(client, 'id' => 1, 'name' => 'John') }
  let(:james) { unicorn_class.new(client, 'id' => 2, 'name' => 'James') }

  include ResourcesHelper

  let!(:unicorn_class) do
    defresource 'Unicorn' do
      path '/unicorns'
      contains_one :horn
      contains_one :unicorn, as: :mother
      contains_one :treasure
      contains_many :unicorns, as: :friends
      contains_many :favorite_foods
    end
  end

  describe '#all' do
    it 'returns all elements of a resource' do
      api.on(:get, '/unicorns') do |response|
        response.body = { 'data' => [john, james].map(&:to_h) }
      end

      expect(query.all)
        .to eq(Asana::Resources::Collection
               .new(client, unicorn_class, [john, james]))
    end
  end

  describe '#find' do
    it 'returns a resource by its id' do
      api.on(:get, '/unicorns/2') do |response|
        response.body = { 'data' => james.to_h }
      end

      expect(query.find('2')).to eq(james)
    end
  end
end
