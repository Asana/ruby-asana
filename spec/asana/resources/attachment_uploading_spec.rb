# frozen_string_literal: true

require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::AttachmentUploading do
  let(:api) { StubAPI.new }
  let(:authentication) do
    Asana::Authentication::TokenAuthentication.new('token')
  end
  let(:client) do
    Asana::HttpClient.new(authentication: authentication, adapter: api.adapter)
  end

  include ResourcesHelper

  mod = described_class
  let!(:unicorn_class) do
    defresource 'Unicorn' do
      include mod

      attr_reader :gid

      def self.plural_name
        'unicorns'
      end
    end
  end

  describe '#attach' do
    let(:arg_matcher) { ->(body) { body.is_a?(Faraday::CompositeReadIO) } }
    let(:unicorn) { unicorn_class.new({ gid: '1' }, client: client) }

    before do
      api.on(:post, '/unicorns/1/attachments', arg_matcher) do |response|
        response.body = { data: { gid: '10' } }
      end
    end

    context 'with a file from the file system' do
      it 'uploads an attachment to a unicorn' do
        attachment = unicorn.attach(filename: __FILE__,
                                    mime: 'image/jpg')

        expect(attachment).to be_a(Asana::Resources::Attachment)
        expect(attachment.gid).to eq('10')
      end
    end

    context 'with an IO' do
      let(:io) do
        ::StringIO.new(<<~CSV)
          Employee;Salary
          "Bill Lumbergh";70000
          "Peter Gibbons";40000
        CSV
      end

      it 'uploads an attachment to a unicorn' do
        attachment = unicorn.attach(io: io,
                                    mime: 'text/csv',
                                    filename: 'salaries.csv')

        expect(attachment).to be_a(Asana::Resources::Attachment)
        expect(attachment.gid).to eq('10')
      end
    end
  end
end
