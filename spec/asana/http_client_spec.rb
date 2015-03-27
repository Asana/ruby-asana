require 'support/stub_api'

RSpec.describe Asana::HttpClient do
  let(:api) { StubAPI.new }
  let(:auth) { Asana::Authentication::TokenAuthentication.new('foo') }
  let(:client) do
    described_class.new(authentication: auth, adapter: api.to_proc)
  end

  describe '#get' do
    it 'performs a GET request against the Asana API' do
      api.on(:get, '/users/me') do |response|
        response.body = { user: 'foo' }
      end

      client.get('/users/me').tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end

  describe '#put' do
    it 'performs a PUT request against the Asana API' do
      api.on(:put, '/users/me', 'name' => 'John') do |response|
        response.body = { user: 'foo' }
      end

      client.put('/users/me', body: { 'name' => 'John' }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end
end
