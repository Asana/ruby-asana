require 'support/stub_api'

RSpec.describe Asana::Client do
  let(:api) { StubAPI.new }
  let(:client) do
    described_class.new do |c|
      c.authentication :api_token, 'foo'
      c.faraday_adapter api.adapter
    end
  end

  context 'exposes HTTP verbs to interact with the API at a lower level' do
    specify '#get' do
      api.on(:get, '/users/me') do |response|
        response.body = { data: { foo: 'bar' } }
      end

      expect(client.get('/users/me').body).to eq('data' => { 'foo' => 'bar' })
    end

    specify '#post' do
      api.on(:post, '/tags', data: { name: 'work' }) do |response|
        response.body = { data: { foo: 'bar' } }
      end

      expect(client.post('/tags', body: { name: 'work' }).body)
        .to eq('data' => { 'foo' => 'bar' })
    end

    specify '#put' do
      api.on(:put, '/tags/1', name: 'work') do |response|
        response.body = { data: { foo: 'bar' } }
      end

      expect(client.put('/tags/1', body: { name: 'work' }).body)
        .to eq('data' => { 'foo' => 'bar' })
    end
  end
end
