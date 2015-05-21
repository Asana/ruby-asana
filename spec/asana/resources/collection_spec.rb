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

  describe '#each' do
    context 'if there is more than one page' do
      it 'transparently iterates over all of them' do
        path = '/unicorns?limit=5'
        api.on(:get, path + '&offset=abc') do |response|
          response.body = { 'next_page' => { 'path' => path + '&offset=def' },
                            'data' => unicorns.drop(5).take(5) }
        end

        api.on(:get, path + '&offset=def') do |response|
          response.body = { 'next_page' => { 'path' => path + '&offset=ghi' },
                            'data' => unicorns.drop(10).take(5) }
        end

        api.on(:get, path + '&offset=ghi') do |response|
          response.body = { 'data' => unicorns.drop(15).take(5) }
        end

        extra = { 'next_page' => { 'path' => path + '&offset=abc' } }
        collection = described_class.new([unicorns.take(5), extra],
                                         type: unicorn_class,
                                         client: client)

        expect(collection.to_a.map(&:id)).to eq((1..20).to_a)
      end
    end

    context 'if there is only one page' do
      it 'iterates over that one' do
        collection = described_class.new([unicorns.take(5), {}],
                                         type: unicorn_class,
                                         client: client)

        expect(collection.to_a.map(&:id)).to eq((1..5).to_a)
      end
    end
  end
end