RSpec.describe Asana::Authentication::OAuth2::BearerTokenAuthentication do
  let(:auth) { described_class.new('MYTOKEN') }

  it 'configures Faraday to use OAuth2 authentication with a bearer token' do
    conn = Faraday.new do |builder|
      auth.configure(builder)
    end
    expect(conn.builder.handlers.first).to eq(FaradayMiddleware::OAuth2)
  end
end
