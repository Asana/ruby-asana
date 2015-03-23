RSpec.describe Asana::Authentication::TokenAuthentication do
  describe described_class do
    let(:auth) { described_class.new('MYTOKEN') }

    it 'configures Faraday to use basic authentication with a token' do
      conn = Faraday.new do |builder|
        auth.configure(builder)
      end
      expect(conn.headers['Authorization']).to eq('Basic TVlUT0tFTjo=')
    end
  end
end
