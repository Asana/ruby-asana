require 'support/stub_api'
require 'support/resources_helper'

RSpec.describe Asana::Resources::Webhook do
  let(:api) { StubAPI.new }
  let(:authentication) do
    Asana::Authentication::TokenAuthentication.new('token')
  end
  let(:client) do
    Asana::HttpClient.new(authentication: authentication, adapter: api.adapter)
  end

  include ResourcesHelper

  let(:webhook_data) do
    {
      gid: "222",
      resource: {
        gid: "111",
        name: 'the resource'
      },
      target: 'https://foo/123',
      active: true
    }
  end

  # rubocop:disable Metrics/AbcSize
  def verify_webhook_data(webhook)
    expect(webhook.gid).to eq(webhook_data[:gid])
    expect(webhook.resource['gid']).to eq(webhook_data[:resource][:gid])
    expect(webhook.resource['name']).to eq(webhook_data[:resource][:name])
    expect(webhook.target).to eq(webhook_data[:target])
    expect(webhook.active).to eq(webhook_data[:active])
  end
  # rubocop:enable Metrics/AbcSize

  it 'creates and deletes a webhook' do
    req = {
      data: {
        resource: "111",
        target: 'https://foo/123'
      }
    }

    api.on(:post, '/webhooks', req) do |response|
      response.body = { data: webhook_data }
    end
    api.on(:delete, '/webhooks/222') do |response|
      response.body = { data: {} }
    end

    webhook = described_class.create(client,
                                     resource: "111",
                                     target: 'https://foo/123')
    verify_webhook_data(webhook)

    webhook.delete_by_id
  end

  it 'gets all webhooks' do
    api.on(:get, '/webhooks', workspace: "1337", per_page: 20) do |response|
      response.body = { data: [webhook_data] }
    end

    webhooks = described_class.get_all(client, workspace: "1337")
    verify_webhook_data(webhooks.first)
    expect(webhooks.length).to eq(1)
  end

  it 'gets a webhook by gid' do
    api.on(:get, '/webhooks/222') do |response|
      response.body = { data: webhook_data }
    end

    webhook = described_class.get_by_id(client, "222")
    verify_webhook_data(webhook)
  end
end
