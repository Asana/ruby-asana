# frozen_string_literal: true

RSpec.describe Asana::Authentication::OAuth2::AccessTokenAuthentication do
  describe '#from_refresh_token' do
    let(:token) do
      instance_double(OAuth2::AccessToken, expired?: false, token: 'TOKEN')
    end

    it 'raises an ArgumentError when required fields are missing' do
      expect do
        described_class.from_refresh_token(token)
      end.to raise_error(ArgumentError)
    end
  end

  describe described_class do
    let(:auth) { described_class.new(token) }

    context 'if the token is not expired' do
      let(:token) do
        instance_double(OAuth2::AccessToken, expired?: false, token: 'TOKEN')
      end

      it 'configures Faraday to use OAuth2 with an access token' do
        allow(token).to receive(:refresh!)
        conn = Faraday.new do |builder|
          auth.configure(builder)
        end
        expect(token).not_to have_received(:refresh!)
        expect(conn.builder.handlers).to include(Faraday::Request::Authorization)
      end
    end

    context 'if the token is expired' do
      let(:token) do
        instance_double(OAuth2::AccessToken, expired?: true, token: 'TOKEN')
      end

      it 'refreshes the token and uses the new one' do
        allow(token).to receive(:refresh!) { token }
        conn = Faraday.new do |builder|
          auth.configure(builder)
        end
        expect(token).to have_received(:refresh!)
        expect(conn.builder.handlers).to include(Faraday::Request::Authorization)
      end
    end
  end
end
