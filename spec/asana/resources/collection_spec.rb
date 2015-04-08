require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Collection do
  let(:api) { StubAPI.new }
  let(:authentication) do
    Asana::Authentication::TokenAuthentication.new('token')
  end
  let(:client) do
    Asana::HttpClient.new(authentication: authentication, adapter: api.adapter)
  end

  include ResourcesHelper

  let!(:world_class) do
    defresource 'World' do
      path '/worlds'
      contains_many :unicorns
    end
  end

  let!(:unicorn_class) do
    defresource 'Unicorn' do
      path '/unicorns'
    end
  end

  let(:worlds) do
    [1, 2].map { |id| world_class.new(client, 'id' => id) }
  end

  let(:unicorns) do
    [1, 2].map { |id| unicorn_class.new(client, 'id' => id) }
  end

  it 'is Enumerable' do
    collection = described_class.new(client: client,
                                     resource_class: world_class,
                                     elements: worlds)
    expect(collection.to_a).to eq(worlds)
  end

  describe '#create' do
    describe 'when the collection is just a generic wrapper' do
      it 'fails with an error' do
        generic = described_class.new(client: client,
                                      resource_class: Asana::Resource,
                                      elements: [])
        expect { generic.create('id' => 99) }.to raise_error(/generic/)
      end
    end

    describe 'when the collection is of a specific resource type' do
      it 'can post a new resource of that type' do
        api.on(:post, '/unicorns', data: { id: 99 }) do |response|
          response.body = { data: { id: 99 } }
        end

        collection = described_class.new(client: client,
                                         resource_class: unicorn_class,
                                         elements: unicorns)

        expect(collection.create('id' => 99))
          .to eq(unicorn_class.new(client, 'id' => 99))
      end

      describe 'when scoped' do
        it 'posts the resource within that scope' do
          api.on(:post, '/worlds/1/unicorns', data: { id: 99 }) do |response|
            response.body = { data: { id: 99 } }
          end

          collection = described_class.new(client: client,
                                           resource_class: unicorn_class,
                                           scope: '/worlds/1',
                                           elements: unicorns)

          expect(collection.create('id' => 99))
            .to eq(unicorn_class.new(client, 'id' => 99))
        end
      end
    end
  end
end
