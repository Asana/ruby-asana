# frozen_string_literal: true

require 'support/stub_api'

RSpec.describe Asana::HttpClient do
  let(:api) { StubAPI.new }
  let(:auth) { Asana::Authentication::TokenAuthentication.new('foo') }
  let(:client) do
    described_class.new(authentication: auth, adapter: api.to_proc)
  end

  describe '#initialize' do
    it "raises an ArgumentError when required fields are missing" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
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

    it 'accepts I/O options' do
      api.on(:get, '/users/me?opt_pretty=true') do |response|
        response.body = { user: 'foo' }
      end

      client.get('/users/me', options: { pretty: true }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end

    it 'accepts I/O options containing arrays' do
      api.on(:get, '/users/me?opt_fields=foo,bar') do |response|
        response.body = { user: 'foo' }
      end

      client.get('/users/me',
                 options: { fields: %w[foo bar] }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end

  describe '#put' do
    it 'performs a PUT request against the Asana API' do
      api.on(:put, '/users/me', 'data' => { 'name' => 'John' }) do |response|
        response.body = { user: 'foo' }
      end

      client.put('/users/me', body: { 'name' => 'John' }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end

    it 'accepts I/O options' do
      api.on(:put, '/users/me',
             'data' => { 'name' => 'John' },
             'options' => { 'fields' => %w[foo bar] }) do |response|
        response.body = { user: 'foo' }
      end

      client.put('/users/me',
                 body: { 'name' => 'John' },
                 options: { fields: %w[foo bar] }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end

  describe '#post' do
    it 'performs a POST request against the Asana API' do
      api.on(:post, '/users/me', 'data' => { 'name' => 'John' }) do |response|
        response.body = { user: 'foo' }
      end

      client.post('/users/me', body: { 'name' => 'John' }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end

    it 'accepts I/O options' do
      api.on(:post, '/users/me',
             'data' => { 'name' => 'John' },
             'options' => { 'fields' => %w[foo bar] }) do |response|
        response.body = { user: 'foo' }
      end

      client.post('/users/me',
                  body: { 'name' => 'John' },
                  options: { fields: %w[foo bar] }).tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq('user' => 'foo')
      end
    end
  end

  describe '#delete' do
    it 'performs a DELETE request against the Asana API' do
      api.on(:delete, '/users/me') do |response|
        response.body = {}
      end

      client.delete('/users/me').tap do |response|
        expect(response.status).to eq(200)
        expect(response.body).to eq({})
      end
    end
  end
end
