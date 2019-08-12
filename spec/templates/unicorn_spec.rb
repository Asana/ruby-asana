require 'support/stub_api'
require_relative 'world'
require_relative 'unicorn'

# rubocop:disable RSpec/FilePath
RSpec.describe Asana::Resources::Unicorn do
  RSpec::Matchers.define :be_john do
    match do |unicorn|
      unicorn.class == described_class &&
        unicorn.gid == "1" &&
        unicorn.name == 'John' &&
        unicorn.world == "123"
    end
  end

  RSpec::Matchers.define :be_laura do
    match do |unicorn|
      unicorn.class == described_class &&
        unicorn.gid == "2" &&
        unicorn.name == 'Laura' &&
        unicorn.world == "184"
    end
  end

  let(:api) { StubAPI.new }
  let(:auth) { Asana::Authentication::TokenAuthentication.new('foo') }
  let(:client) do
    Asana::HttpClient.new(authentication: auth, adapter: api.to_proc)
  end

  let(:john_data) { { 'gid' => "1", 'name' => 'John', 'world' => "123" } }
  let(:laura_data) { { 'gid' => "2", 'name' => 'Laura', 'world' => "184" } }

  describe '.plural_name' do
    it 'returns the resource plural name' do
      expect(described_class.plural_name).to eq('unicorns')
    end
  end

  describe '.create' do
    it 'creates a new unicorn, with the world passed in as a param' do
      api.on(:post, '/unicorns', data: { name: 'John',
                                         world: "123" }) do |response|
        response.body = { data: john_data }
      end
      john = described_class.create(client, name: 'John', world: "123")
      expect(john).to be_john
    end
  end

  describe '.create_in_world' do
    it 'creates a new unicorn, with the world passed in the URL' do
      api.on(:post,
             '/worlds/123/unicorns',
             data: { name: 'John' }) do |response|
        response.body = { data: john_data }
      end
      john = described_class.create_in_world(client, name: 'John', world: "123")
      expect(john).to be_john
    end
  end

  describe '.find_by_id' do
    it 'finds a unicorn by id' do
      api.on(:get, '/unicorns/1') do |response|
        response.body = { data: john_data }
      end
      john = described_class.find_by_id(client, 1)
      expect(john).to be_john
    end
  end

  describe '.find_all' do
    it 'finds all unicorns in all worlds of any breed' do
      api.on(:get, '/unicorns') do |response|
        response.body = { data: [john_data, laura_data] }
      end

      unicorns = described_class.find_all(client)
      expect(unicorns).to be_a(Asana::Resources::Collection)
      expect(unicorns.size).to eq(2)

      john, laura = unicorns.to_a
      expect(john).to be_john
      expect(laura).to be_laura
    end

    it 'finds all unicorns by world' do
      api.on(:get, '/unicorns?world=123&limit=20') do |response|
        response.body = { data: [john_data] }
      end

      unicorns = described_class.find_all(client, world: "123")
      expect(unicorns).to be_a(Asana::Resources::Collection)
      expect(unicorns.size).to eq(1)
      expect(unicorns.first).to be_john
    end

    it 'finds all unicorns by breed' do
      api.on(:get, '/unicorns?breed=magical&limit=20') do |response|
        response.body = { data: [laura_data] }
      end

      unicorns = described_class.find_all(client, breed: 'magical')
      expect(unicorns).to be_a(Asana::Resources::Collection)
      expect(unicorns.size).to eq(1)
      expect(unicorns.first).to be_laura
    end

    it 'paginates unicorns' do
      api.on(:get, '/unicorns?limit=1') do |response|
        response.body = { data: [john_data],
                          next_page: { path: '/unicorns?limit=1&offset=xyz' } }
      end

      api.on(:get, '/unicorns?limit=1&offset=xyz') do |response|
        response.body = { data: [laura_data] }
      end

      unicorns = described_class.find_all(client, per_page: 1)
      expect(unicorns).to be_a(Asana::Resources::Collection)
      expect(unicorns.size).to eq(2)
      expect(unicorns.first).to be_john
      expect(unicorns.to_a.last).to be_laura
    end

    it 'accepts I/O options' do
      api.on(:get, '/unicorns?opt_pretty=true') do |response|
        response.body = { data: [john_data] }
      end

      unicorns = described_class.find_all(client, options: { pretty: true })
      expect(unicorns).to be_a(Asana::Resources::Collection)
      expect(unicorns.size).to eq(1)
      expect(unicorns.first).to be_john
    end
  end

  describe '.find_by_world' do
    it 'finds all unicorns by world in the URL' do
      api.on(:get, '/worlds/123/unicorns') do |response|
        response.body = { data: [john_data] }
      end

      unicorns = described_class.find_by_world(client, world: "123")
      expect(unicorns).to be_a(Asana::Resources::Collection)
      expect(unicorns.size).to eq(1)
      expect(unicorns.first).to be_john
    end
  end

  describe '#update' do
    it 'updates a unicorn' do
      api.on(:put, '/unicorns/1', data: { name: 'Jan' }) do |response|
        response.body = { data: john_data.merge(name: 'Jan') }
      end

      john = described_class.new(john_data, client: client)
      jan = john.update(name: 'Jan')
      expect(jan.gid).to eq("1")
      expect(jan.name).to eq('Jan')
      expect(jan.world).to eq("123")
    end
  end

  describe '#paws' do
    it 'returns a collection of paws as generic resources' do
      paw_data = { id: 9, size: 4 }
      api.on(:get, '/unicorns/1/paws') do |response|
        response.body = { data: [paw_data] }
      end

      john = described_class.new(john_data, client: client)
      paws = john.paws
      expect(paws).to be_a(Asana::Resources::Collection)
      expect(paws.size).to eq(1)
      expect(paws.first).to be_a(Asana::Resources::Resource)
      expect(paws.first.size).to eq(4)
    end
  end

  describe '#add_paw' do
    it 'adds an existing paw to a unicorn' do
      paw_data = { gid: 9, size: 4 }
      api.on(:post, '/unicorns/1/paws', data: { paw: 9 }) do |response|
        response.body = { data: paw_data }
      end

      john = described_class.new(john_data, client: client)
      paw = john.add_paw(paw: 9)
      expect(paw.size).to eq(4)
    end
  end

  describe '#add_friends' do
    it 'adds existing friends to a unicorn' do
      api.on(:post, '/unicorns/1/friends', data: { friends: [2] }) do |response|
        response.body = { data: john_data }
      end

      john = described_class.new(john_data, client: client)
      expect(john.add_friends(friends: [2])).to be_john
    end
  end

  describe '#get_world' do
    it 'returns the world of the unicorn, with its inferred type' do
      api.on(:get, '/unicorns/1/getWorld') do |response|
        response.body = { data: { gid: "123" } }
      end

      john = described_class.new(john_data, client: client)
      world = john.get_world
      expect(world).to be_a(Asana::Resources::World)
      expect(world.gid).to eq("123")
    end
  end

  describe '#delete' do
    it 'deletes a unicorn' do
      api.on(:delete, '/unicorns/1') do |response|
        response.body = { data: {} }
      end

      john = described_class.new(john_data, client: client)
      expect(john.delete).to eq(true)
    end
  end
end
# rubocop:enable RSpec/FilePath
