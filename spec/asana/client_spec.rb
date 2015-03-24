require 'support/stub_api'

RSpec.describe Asana::Client do
  let(:api) { StubAPI.new }

  describe '#initialize' do
    it 'configures a new client with OAuth2 and a refresh token' do
      client = described_class.new do |c|
        c.authentication :api_token, 'foo'
        c.faraday_adapter api.adapter
      end

      expect(client).to be_a(Asana::Client)
    end
  end
end
