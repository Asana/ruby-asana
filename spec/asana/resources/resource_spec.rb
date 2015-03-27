require 'support/stub_api'

RSpec.describe Asana::Resources::Resource do
  let(:api) { StubAPI.new }

  def klass(name, parent, &body)
    Class.new(parent) do
      define_singleton_method(:==) { |other| self.name == other.name }
      define_singleton_method(:name) { name }
      define_singleton_method(:to_s) { name }
      define_singleton_method(:inspect) { name }
      instance_eval(&body)
    end
  end

  let!(:treasure_class) do
    klass('Asana::Resources::Treasure', described_class) do
      path '/treasures'
    end
  end

  let!(:unicorn_class) do
    klass('Asana::Resources::Unicorn', described_class) do
      path '/unicorns'
      contains_one :horn
      contains_one :unicorn, as: :mother
      contains_one :treasure
      contains_many :unicorns, as: :friends
      contains_many :favorite_foods
    end
  end

  let(:authentication) do
    Asana::Authentication::TokenAuthentication.new('token')
  end

  let(:client) do
    Asana::HttpClient.new(authentication: authentication, adapter: api.adapter)
  end

  it 'auto-vivifies plain properties of the resource' do
    unicorn = unicorn_class.new(client, 'name' => 'John')
    expect(unicorn.name).to eq('John')
  end

  describe '#refresh' do
    it 'refreshes by re-fetching itself from the API' do
      unicorn = unicorn_class.new(client, 'id' => 10, 'name' => 'John')
      api.on(:get, '/unicorns/10') do |response|
        response.body = { 'data' => { 'name' => 'Jimmy', 'age' => 30 } }
      end
      refreshed_unicorn = unicorn.refresh
      expect(refreshed_unicorn).to_not eq(unicorn)
      expect(refreshed_unicorn.name).to eq('Jimmy')
      expect(refreshed_unicorn.age).to eq(30)
    end

    it 'returns itself if it does not have enough data to refresh' do
      unicorn = unicorn_class.new(client, 'name' => 'John')
      same_unicorn = unicorn.refresh
      expect(same_unicorn).to eq(unicorn)
    end

    it 'raises an error if it does not understand the response body' do
      unicorn = unicorn_class.new(client, 'id' => 10, 'name' => 'John')
      api.on(:get, '/unicorns/10') do |response|
        response.body = { 'malformed' => 'body' }
      end
      expect { unicorn.refresh }.to raise_error(/Unexpected/)
    end
  end

  describe 'single contained resources' do
    it 'expose nilable methods' do
      unicorn = unicorn_class.new(client)
      expect(unicorn.horn).to be_nil
    end

    it 'wrap values in a generic Resource object' do
      unicorn = unicorn_class.new(client, 'horn' => { 'id' => 10 })
      expect(unicorn.horn).to eq(described_class.new(client, 'id' => 10))
    end

    it 'use a more specific subclass of Resource if available' do
      unicorn = unicorn_class.new(client,
                                  'mother' => { 'id' => 22 },
                                  'treasure' => { 'id' => 99 })
      expect(unicorn.mother).to eq(unicorn_class.new(client, 'id' => 22))
      expect(unicorn.treasure).to eq(treasure_class.new(client, 'id' => 99))
    end

    it 'are wrapped even when they are not declared in the DSL' do
      unicorn = unicorn_class.new(client, 'father' => { 'id' => 22 })
      expect(unicorn.father).to eq(described_class.new(client, 'id' => 22))
    end
  end

  describe 'multiple contained resources' do
    it 'expose methods defaulting to empty collections' do
      unicorn = unicorn_class.new(client)
      expect(unicorn.friends)
        .to eq(Asana::Resources::Collection.new(client, unicorn_class, []))
    end

    it 'wrap values in a generic Collection<Resource> object' do
      unicorn = unicorn_class.new(client,
                                  'favorite_foods' => [{ 'name' => 'bread' }])
      expect(unicorn.favorite_foods)
        .to eq(Asana::Resources::Collection
               .new(client,
                    described_class,
                    [described_class.new(client, 'name' => 'bread')]))
    end

    it 'use a more specific subclass of Resource if available' do
      unicorn = unicorn_class.new(client, 'friends' => [{ 'id' => 22 }])
      expect(unicorn.friends)
        .to eq(Asana::Resources::Collection
               .new(client,
                    unicorn_class,
                    [unicorn_class.new(client, 'id' => 22)]))
    end

    it 'are wrapped even when they are not declared in the DSL' do
      unicorn = unicorn_class.new(client, 'enemies' => [{ 'id' => 22 }])
      expect(unicorn.enemies)
        .to eq(Asana::Resources::Collection
               .new(client,
                    described_class,
                    [described_class.new(client, 'id' => 22)]))
    end
  end
end
