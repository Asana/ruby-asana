require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Collection do
  let(:api) { StubAPI.new }
  let(:auth) { Asana::Authentication::TokenAuthentication.new('foo') }
  let(:client) do
    Asana::HttpClient.new(authentication: auth, adapter: api.to_proc)
  end

  include ResourcesHelper

  let!(:unicorn_class) do
    defresource 'Unicorn' do
      attr_reader :id
    end
  end

  let(:unicorns) { (1..20).to_a.map { |id| { 'id' => id } } }

  describe '#next_page' do
    context 'if there are more pages' do
      it 'returns the next page of the collection' do
        path = '/unicorns?limit=5'
        api.on(:get, path) do |response|
          response.body = { 'next_page' => { 'path' => path + '&offset=abc' },
                            'data' => unicorns.drop(5).take(5) }
        end
        extra = { 'next_page' => { 'path' => path } }
        collection = described_class.new([unicorns.take(5), extra],
                                         type: unicorn_class,
                                         client: client)

        nxt = collection.next_page
        expect(nxt).to be_a(described_class)
        expect(nxt.map(&:id)).to eq((6..10).to_a)
      end
    end

    context 'if there are no more pages' do
      it 'returns nil' do
        collection = described_class.new([unicorns.take(5), {}],
                                         type: unicorn_class,
                                         client: client)

        expect(collection.next_page).to be_nil
      end
    end
  end
end
