# rubocop:disable RSpec/FilePath
RSpec.describe Asana::Authentication::OAuth2::BearerTokenAuthentication do
  let(:token) { 'MYTOKEN' }
  let(:auth) { described_class.new(token) }
  let(:conn) do
    Faraday.new do |builder|
      auth.configure(builder)
    end
  end

  it 'configures Faraday to use OAuth2 authentication with a bearer token' do
    expect(conn.builder.handlers).to include(Faraday::Request::Authorization)
  end
end
# rubocop:enable RSpec/FilePath
