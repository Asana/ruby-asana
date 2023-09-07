# frozen_string_literal: true

RSpec.describe Asana::Authentication::OAuth2::Client do
  let(:client) do
    described_class.new(client_id: 'CLIENT_ID',
                        client_secret: 'CLIENT_SECRET',
                        redirect_uri: 'http://redirect_uri.com')
  end

  describe '#initialize' do
    it 'raises an ArgumentError when required fields are missing' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe '#authorize_url' do
    it 'returns the OAuth2 authorize url' do
      expect(client.authorize_url)
        .to eq('https://app.asana.com/-/oauth_authorize?client_id=CLIENT_ID' \
               '&redirect_uri=http%3A%2F%2Fredirect_uri.com&response_type=code')
    end
  end
end
