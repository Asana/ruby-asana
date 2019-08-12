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
    it 'uploads an attachment to a unicorn' do
      arg_matcher = ->(body) { body.is_a?(Faraday::CompositeReadIO) }
      api.on(:post, '/unicorns/1/attachments', arg_matcher) do |response|
        response.body = { data: { gid: "10" } }
      end
      unicorn = unicorn_class.new({ gid: "1" }, client: client)
      attachment = unicorn.attach(filename: __FILE__,
                                  mime: 'image/jpg',
                                  name: 'file')
      expect(attachment).to be_a(Asana::Resources::Attachment)
      expect(attachment.gid).to eq("10")
    end
  end
end
