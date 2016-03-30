require 'multi_json'

RSpec.describe Asana::HttpClient::ErrorHandling do
  describe '.handle' do
    def failed_response(status, headers: {}, body: {})
      lambda do
        raise Faraday::ClientError.new(nil, status: status,
                                            body: MultiJson.dump(body),
                                            headers: headers)
      end
    end

    context 'when the response is successful' do
      it 'returns the result of the block' do
        expect(described_class.handle { 3 }).to eq(3)
      end
    end

    context 'when the response has status 400' do
      let(:request) do
        body = { 'errors' => [{ 'message' => 'Invalid field' }] }
        failed_response(400, body: body)
      end

      it 'raises an InvalidRequest exception containing the errors' do
        expect { described_class.handle(&request) }.to raise_error do |error|
          expect(error).to be_a(Asana::Errors::InvalidRequest)
          expect(error.errors).to eq(['Invalid field'])
        end
      end
    end

    context 'when the response has status 401' do
      let(:request) { failed_response(401) }

      it 'raises a NotAuthorized exception' do
        expect { described_class.handle(&request) }
          .to raise_error(Asana::Errors::NotAuthorized)
      end
    end

    context 'when the response has status 403' do
      let(:request) { failed_response(403) }

      it 'raises a Forbidden exception' do
        expect { described_class.handle(&request) }
          .to raise_error(Asana::Errors::Forbidden)
      end
    end

    context 'when the response has status 404' do
      let(:request) { failed_response(404) }

      it 'raises a NotFound exception' do
        expect { described_class.handle(&request) }
          .to raise_error(Asana::Errors::NotFound)
      end
    end

    context 'when the response has status 429' do
      let(:request) { failed_response(429, headers: { 'Retry-After' => 20 }) }

      it 'raises a RateLimitEnforced exception with seconds to wait' do
        expect { described_class.handle(&request) }.to raise_error do |error|
          expect(error).to be_a(Asana::Errors::RateLimitEnforced)
          expect(error.retry_after_seconds).to eq(20)
        end
      end
    end

    context 'when the response has status 500' do
      let(:request) do
        body = { 'errors' => [{ 'phrase' => 'A quick lazy dog jumps' }] }
        failed_response(500, body: body)
      end

      it 'raises a ServerError exception with a unique phrase' do
        expect { described_class.handle(&request) }.to raise_error do |error|
          expect(error).to be_a(Asana::Errors::ServerError)
          expect(error.phrase).to eq('A quick lazy dog jumps')
        end
      end
    end

    context 'when the response fails with whatever other status' do
      let(:request) { failed_response(510) }

      it 'raises a generic APIError exception' do
        expect { described_class.handle(&request) }
          .to raise_error(Asana::Errors::APIError)
      end
    end
  end
end
