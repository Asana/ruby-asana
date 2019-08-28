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
      attr_reader :gid
    end
  end

  let(:unicorns) { (1..20).to_a.map { |gid| { 'gid' => gid } } }

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

        expect(collection.to_a.map(&:gid)).to eq((1..20).to_a)
      end
    end

    context 'if there is only one page' do
      it 'iterates over that one' do
        collection = described_class.new([unicorns.take(5), {}],
                                         type: unicorn_class,
                                         client: client)

        expect(collection.to_a.map(&:gid)).to eq((1..5).to_a)
      end
    end

    context 'as a lazy collection' do
      it 'fetches only as many pages as needed' do
        path = '/unicorns?limit=5'
        api.on(:get, path + '&offset=abc') do |response|
          response.body = { 'next_page' => { 'path' => path + '&offset=def' },
                            'data' => unicorns.drop(5).take(5) }
        end

        api.on(:get, path + '&offset=def') do |response|
          response.body = { 'next_page' => { 'path' => path + '&offset=ghi' },
                            'data' => unicorns.drop(10).take(5) }
        end

        extra = { 'next_page' => { 'path' => path + '&offset=abc' } }
        lazy = described_class.new([unicorns.take(5), extra],
                                   type: unicorn_class,
                                   client: client).lazy

        expect(lazy.drop(6).take(6).map(&:gid).to_a).to eq((7..12).to_a)
      end
    end
  end

  describe '#elements' do
    it 'returns the current page of elements' do
      collection = described_class.new([unicorns.take(5), {}],
                                       type: unicorn_class,
                                       client: client)
      expect(collection.elements.map(&:gid)).to eq((1..5).to_a)
    end
  end

  describe '#next_page' do
    it 'returns the next page of elements as an Asana::Collection' do
      path = '/unicorns?limit=5'
      extra = { 'next_page' => { 'path' => path + '&offset=abc' } }
      api.on(:get, path + '&offset=abc') do |response|
        response.body = { 'next_page' => { 'path' => path + '&offset=def' },
                          'data' => unicorns.drop(5).take(5) }
      end
      collection = described_class.new([unicorns.take(5), extra],
                                       type: unicorn_class,
                                       client: client)
      nxt = collection.next_page
      expect(nxt.elements.map(&:gid)).to eq((6..10).to_a)
    end
  end
end
