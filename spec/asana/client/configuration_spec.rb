RSpec.describe Asana::Client::Configuration do
  describe '#authentication' do
    context 'with :oauth2' do
      context 'and an ::OAuth2::AccessToken object' do
        it 'sets authentication with an OAuth2 access token' do
          auth = described_class.new.tap do |config|
            config.authentication :oauth2,
                                  ::OAuth2::AccessToken.new(nil, 'token')
          end.to_h[:authentication]

          expect(auth)
            .to be_a(Asana::Authentication::OAuth2::AccessTokenAuthentication)
        end
      end

      context 'and a hash with a :refresh_token' do
        context 'and valid client credentials' do
          before do
            # rubocop:disable RSpec/AnyInstance
            expect_any_instance_of(Asana::Authentication::OAuth2::Client)
              .to receive(:token_from_refresh_token)
              .with('refresh_token') do
                ::OAuth2::AccessToken.new(nil, 'token')
              end
            # rubocop:enable RSpec/AnyInstance
          end

          it 'sets authentication with an OAuth2 access token' do
            auth = described_class.new.tap do |config|
              config.authentication :oauth2,
                                    refresh_token: 'refresh_token',
                                    client_id: 'client_id',
                                    client_secret: 'client_id',
                                    redirect_uri: 'http://redirect_uri'
            end.to_h[:authentication]

            expect(auth)
              .to be_a(Asana::Authentication::OAuth2::AccessTokenAuthentication)
          end
        end

        context 'and incomplete client credentials' do
          it 'fails with an error' do
            expect do
              described_class.new.tap do |config|
                config.authentication :oauth2,
                                      refresh_token: 'refresh_token',
                                      client_id: 'client_id'
              end
            end.to raise_error(ArgumentError, /missing/i)
          end
        end
      end

      context 'and a hash with a :bearer_token' do
        it 'sets authentication with an OAuth2 bearer token' do
          auth = described_class.new.tap do |config|
            config.authentication :oauth2, bearer_token: 'token'
          end.to_h[:authentication]

          expect(auth)
            .to be_a(Asana::Authentication::OAuth2::BearerTokenAuthentication)
        end
      end
    end

    context 'with :access_token' do
      it 'sets authentication with an API token' do
        auth = described_class.new.tap do |config|
          config.authentication :access_token, 'token'
        end.to_h[:authentication]

        expect(auth).to be_a(Asana::Authentication::OAuth2::BearerTokenAuthentication)
      end
    end
  end

  describe '#faraday_adapter' do
    it 'sets a custom faraday adapter for the HTTP requests' do
      adapter = described_class.new.tap do |config|
        config.faraday_adapter :typhoeus
      end.to_h[:faraday_adapter]

      expect(adapter).to eq(:typhoeus)
    end
  end

  describe '#configure_faraday' do
    it 'passes in a custom configuration block for the Faraday connection' do
      faraday_config = described_class.new.tap do |config|
        config.configure_faraday do |conn|
          conn.use :some_middleware
        end
      end.to_h[:faraday_configuration]

      expect(faraday_config).to be_a(Proc)
    end
  end

  describe '#debug_mode' do
    it 'configures the client to be more verbose' do
      debug_mode = described_class.new.tap(&:debug_mode).to_h[:debug_mode]
      expect(debug_mode).to eq(true)
    end
  end
end
