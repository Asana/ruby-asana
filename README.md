# Asana

A Ruby client for the 1.0 version of the Asana API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-asana'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-asana

## Usage

First, you'll need to create an instance of `Asana::Client` and configure it
with your preferred authentication method (see the Authentication section below
for more complex scenarios) and other options.

The most minimal example would be as follows:

```ruby
require 'asana'

client = Asana::Client.new do |c|
  c.authentication :api_token, 'my_api_token'
end

client.do_something
```

A full-blown customized client using OAuth2 wih a previously obtained refresh
token, Typhoeus as a Faraday adapter, a custom user agent and custom Faraday
middleware:

```ruby
require 'asana'

client = Asana::Client.new do |c|
  c.authentication :oauth2,
                   refresh_token: 'abc',
                   client_id: 'bcd',
                   client_secret: 'cde',
                   redirect_uri: 'http://example.org/auth'
  c.faraday_adapter :typhoeus
  c.configure_faraday { |conn| conn.use SomeFaradayMiddleware }
end

workspace = client.workspaces.find(12)
workspace.users
# => #<Asana::Collection<User> ...>
workspace.tags.create(name: 'foo')
# => #<Asana::Tag id: ..., name: "foo">
```

### Authentication

This gem supports authenticating against the Asana API with either an API token or through OAuth2.

#### API Token

```ruby
Asana::Client.new do |c|
  c.authentication :api_token, 'my_api_token'
end
```

#### OAuth2

Authenticating through OAuth2 is preferred. There are many ways you can do this.

##### With a plain bearer token (doesn't support auto-refresh)

If you have a plain bearer token obtained somewhere else and you don't mind not
having your token auto-refresh, you can authenticate with it as follows:

```ruby
Asana::Client.new do |c|
  c.authentication :oauth2, bearer_token: 'my_bearer_token'
end
```

##### With a refresh token and client credentials

If you obtained a refresh token, you can use it together with your client
credentials to authenticate:

```ruby
Asana::Client.new do |c|
  c.authentication :oauth2,
                   refresh_token: 'abc',
                   client_id: 'bcd',
                   client_secret: 'cde',
                   redirect_uri: 'http://example.org/auth'
end
```

##### With an ::OAuth2::AccessToken object (from `omniauth-asana` for example)

If you use `omniauth-asana` or a browser-based OAuth2 authentication strategy in
general, possibly because your application is a web application, you can reuse
those credentials to authenticate with this API client. Here's how to do it:

```ruby
# TODO: Verify
client = strategy.client # from your omniauth oauth2 strategy
omniauth = request.env['omniauth.auth']
access_token = OAuth2::AccessToken.from_hash client, omniauth['credentials']
Asana::Client.new do |c|
  c.authentication :oauth2, access_token
end
```

##### Using an OAuth2 offline authentication flow (for CLI applications)

If your application can't receive HTTP requests and thus you can't use
`omniauth-asana`, for example if it's a CLI application, you can authenticate as
follows:

```ruby
# TODO: Expose in a more convenient namespace
access_token = Asana::Authentication::OAuth2.offline_flow
Asana::Client.new do |c|
  c.authentication :oauth2, access_token
end
```

This will print an authorization URL on STDOUT, and block until you paste in the
authorization code, which you can get by visiting that URL and granting the
necessary permissions.

### Error handling

In any request against the Asana API, there a number of errors that could
arise. Those are well documented in the [Asana API Documentation][apidocs], and
are represented as exceptions under the namespace `Asana::Errors`.

All errors are subclasses of `Asana::Errors::APIError`, so make sure to rescue
instances of this class if you want to handle them yourself.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

Run the build with `rake`. This is equivalent to:

    $ rake spec && rake rubocop && rake yard

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/asana/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[apidocs]: https://asana.com/developers
