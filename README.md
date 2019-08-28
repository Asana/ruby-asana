# Asana

[![Gem Version](https://badge.fury.io/rb/asana.svg)](http://badge.fury.io/rb/asana)
[![Build Status](https://travis-ci.org/Asana/ruby-asana.svg?branch=master)](https://travis-ci.org/Asana/ruby-asana)
[![Code Climate](https://codeclimate.com/github/Asana/ruby-asana/badges/gpa.svg)](https://codeclimate.com/github/Asana/ruby-asana)


A Ruby client for the 1.0 version of the Asana API.

Supported rubies:

* MRI 2.0.0 up to 2.2.x stable

## Required: Security procedures for outdated OpenSSL versions

Older versions of OpenSSL can cause a problem when using `ruby-asana` In particular, at the time of this writing, at least **MacOS X 10.11 and below** ship with a very old version of OpenSSL:
    
    $ openssl version
    OpenSSL 0.9.8zh 14 Jan 2016

OpenSSL 0.9.8 was first released in 2005, and therefore only supports TLS (Transport Layer Security) version 1.0. Asana has deprecated and stopped accepting requests for clients which do not suport [TLS 1.0 and above](https://asa.na/tls), which unfortunately includes any software linked against this version of the library - this includes both the MacOS X provided Ruby interpreter and any homebrew installed Ruby that is not specifically configured to link against a newer version.

To see if your Ruby version is affected, run
   
    $ ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'

If the version printed at the command line is older than `1.0.1`, when, in 2012, OpenSSL first supported TLS 1.1 and 1.2, you will not be able to use `ruby-asana` to connect to Asana. Specifically, you will recieve `400 Bad Request` responses with an error message in the response body about the lack of support for TLS 1.1 and above.

Asana highly recommends using a Ruby installation manager, either RVM or `rbenv`. Instructions on how to install an up-to-date `ruby` for each of these are below.

### Solution when using RVM

RVM makes it easy to install both an updated OpenSSL and a Ruby interpreter that links to it. If you are using MacPorts or Homebrew, you're probably fine out of the box; RVM favors package management using either one of these to satisfy dependencies, and so can keep your ruby up to date automatically. If you are not using these, consider using them, as they're very simple to install and use.

If you don't use your package manager, you can use RVM's [package manager](https://rvm.io/packages) to install from source.

If you want to build OpenSSL from source yourself, you have to specify how to link to this OpenSSL installation:

    $ rvm install ruby-{version} --with-openssl-dir={ssl_dir}
          # Specify your openssl path prefix, wherever openssl dirs 
          # "bin", "include", and "lib" are installed; usually
          # "/usr" for system installs, or $PREFIX for configure/make locally.
    $ ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION' # Verify inside Ruby
    OpenSSL 1.0.2h  3 May 2016

If you see the version of OpenSSL greater than OpenSSL 1.0.1, then you're all set to start using `ruby-asana`

### Solution when using rbenv

Similar to RVM, rbenv compiles rubies with knowledge of MacPorts and Homebrew libraries. When a newer version of OpenSSL is installed via the method above, all rubies built (after that time of course) will link to the newer version of OpenSSL.

If you don't use a package manager, as above, you can build by explicitly supplying the directory in which to find OpenSSL:

    $ RUBY_CONFIGURE_OPTS=--with-openssl-dir=/opt/local rbenv install ruby-{version}
          # Specify your openssl path prefix, wherever openssl dirs 
          # "bin", "include", and "lib" are installed; usually
          # "/usr" for system installs, or $PREFIX for configure/make locally.
    $ ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION' # Verify inside Ruby
    OpenSSL 1.0.2h  3 May 2016

## Gem Installation
Add this line to your application's Gemfile:

```ruby
gem 'asana'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install asana

## Usage

To do anything, you'll need always an instance of `Asana::Client` configured
with your preferred authentication method (see the Authentication section below
for more complex scenarios) and other options.

The most minimal example would be as follows:

```ruby
require 'asana'

client = Asana::Client.new do |c|
  c.authentication :access_token, 'personal_access_token'
end

client.workspaces.find_all.first
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

workspace = client.workspaces.find_by_id(12)
workspace.users
# => #<Asana::Collection<User> ...>
client.tags.create_in_workspace(workspace: workspace.id, name: 'foo')
# => #<Asana::Tag id: ..., name: "foo">
```

All resources are exposed as methods on the `Asana::Client` instance. Check out
the [documentation for each of them][docs].

### Authentication

This gem supports authenticating against the Asana API with either an API token or through OAuth2.

#### Personal Access Token

```ruby
Asana::Client.new do |c|
  c.authentication :access_token, 'personal_access_token'
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
those credentials to authenticate with this API client. Here's how to do it from
the callback method:

```ruby
# assuming we're using Sinatra and omniauth-asana
get '/auth/:name/callback' do
  creds = request.env["omniauth.auth"]["credentials"].tap { |h| h.delete('expires') }
  strategy = request.env["omniauth.strategy"]

  # We need to refresh the omniauth OAuth2 token
  access_token = OAuth2::AccessToken.from_hash(strategy.client, creds).refresh!

  $client = Asana::Client.new do |c|
    c.authentication :oauth2, access_token
  end
 
  redirect '/'
end
```

See `examples/omniauth_integration.rb` for a working example of this.

##### Using an OAuth2 offline authentication flow (for CLI applications)

If your application can't receive HTTP requests and thus you can't use
`omniauth-asana`, for example if it's a CLI application, you can authenticate as
follows:

```ruby
access_token = Asana::Authentication::OAuth2.offline_flow(client_id: ...,
                                                          client_secret: ...)
client = Asana::Client.new do |c|
  c.authentication :oauth2, access_token
end

client.tasks.find_by_id(12)
```

This will print an authorization URL on STDOUT, and block until you paste in the
authorization code, which you can get by visiting that URL and granting the
necessary permissions.

### Pagination

Whenever you ask for a collection of resources, you can provide a number of
results per page to fetch, between 1 and 100. If you don't provide any, it
defaults to 20.

```ruby
my_tasks = client.tasks.find_by_tag(tag: tag_id, per_page: 5)
# => #<Asana::Collection<Task> ...>
```

An `Asana::Collection` is a paginated collection -- it holds the first
`per_page` results, and a reference to the next page if any.

When you iterate an `Asana::Collection`, it'll transparently keep fetching all
the pages, and caching them along the way:

```ruby
my_tasks.size # => 23, not 5
my_tasks.take(14)
# => [#<Asana::Task ...>, #<Asana::Task ...>, ... until 14]
```

#### Manual pagination

If you only want to deal with one page at a time and manually paginate, you can
get the elements of the current page with `#elements` and ask for the next page
with `#next_page`, which will return an `Asana::Collection` with the next page
of elements:

```ruby
my_tasks.elements # => [#<Asana::Task ...>, #<Asana::Task ...>, ... until 5]
my_tasks.next_page # => #<Asana::Collection ...>
```

#### Lazy pagination

Because an `Asana::Collection` represents the entire collection, it is often
handy to just take what you need from it, rather than let it fetch all its
contents from the network. You can accomplish this by turning it into a lazy
collection with `#lazy`:

```ruby
# let my_tasks be an Asana::Collection of 10 pages of 100 elements each
my_tasks.lazy.drop(120).take(15).to_a
# Fetches only 2 pages, enough to get elements 120 to 135
# => [#<Asana::Task ...>, #<Asana::Task ...>, ...]
```

### Error handling

In any request against the Asana API, there a number of errors that could
arise. Those are well documented in the [Asana API Documentation][apidocs], and
are represented as exceptions under the namespace `Asana::Errors`.

All errors are subclasses of `Asana::Errors::APIError`, so make sure to rescue
instances of this class if you want to handle them yourself.

### I/O options

All requests (except `DELETE`) accept extra I/O options
[as documented in the API docs][io]. Just pass an extra `options` hash to any
request:

```ruby
client.tasks.find_by_id(12, options: { expand: ['workspace'] })
```

### Attachment uploading

To attach a file to a task or a project, you just need its absolute path on your
filesystem and its MIME type, and the file will be uploaded for you:

```ruby
task = client.tasks.find_by_id(12)
attachment = task.attach(filename: '/absolute/path/to/my/file.png',
                         mime: 'image/png')
attachment.name # => 'file.png'
```

### Event streams

To subscribe to an event stream of a task or a project, just call `#events` on
it:

```ruby
task = client.tasks.find_by_id(12)
task.events # => #<Asana::Events ...>

# You can do the same with only the task id:
events = client.events.for(task.id)
```

An `Asana::Events` object is an infinite collection of `Asana::Event`
instances. Be warned that if you call `#each` on it, it will block forever!

Note that, by default, an event stream will wait at least 1 second between
polls, but that's configurable with the `wait` parameter:

```ruby
# wait at least 3 and a half seconds between each poll to the API
task.events(wait: 3.5) # => #<Asana::Events ...>
```

There are some interesting things you can do with an event stream, as it is a
normal Ruby Enumerable. Read below to get some ideas.

#### Subscribe to the event stream with a callback, polling every 2 seconds

```ruby
# Run this in another thread so that we don't block forever
events = client.tasks.find_by_id(12).events(wait: 2)
Thread.new do
  events.each do |event|
    notify_someone "New event arrived! #{event}"
  end
end
```

#### Make the stream lazy and filter it by a specific pattern

To do that we need to call `#lazy` on the `Events` instance, just like with any
other `Enumerable`.

```ruby
events = client.tasks.find_by_id(12).events
only_change_events = events.lazy.select { |event| event.action == 'changed' }
Thread.new do
  only_change_events.each do |event|
    notify_someone "New change event arrived! #{event}"
  end
end
```

### Asana Change Warnings

You will receive warning logs if performing requests that may be affected by a deprecation. The warning contains a link that explains the deprecation.

If you receive one of these warnings, you should:
* Read about the deprecation.
* Resolve sections of your code that would be affected by the deprecation.
* Add the deprecation flag to your "asana-enable" header.

You can add global headers, by setting default_headers

    c.default_headers "asana-enable" => "string_ids"
    
Or you can add a header field to the options of each request.

If you would rather suppress these warnings, you can set

    c.log_asana_change_warnings false

## Development

You'll need Ruby 2.1+ and Node v0.10.26+ / NPM 1.4.3+ installed.

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/console` for an interactive prompt that will allow you to experiment.

Run the build with `rake`. This is equivalent to:

    $ rake spec && rake rubocop && rake yard

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing a new version

To release a new version, run either of these commands:

    rake bump:patch
    rake bump:minor
    rake bump:major

This will: update `lib/asana/version.rb`, commit and tag the commit. Then you
just need to `push --tags` to let Travis build and release the new version to
Rubygems:

    git push --tags

### Code generation

The specific Asana resource classes (`Tag`, `Workspace`, `Task`, etc) are
generated code, hence they shouldn't be modified by hand. The code that
generates it lives in `lib/templates/resource.ejs`, and is tested by generating
`spec/templates/unicorn.rb` and running `spec/templates/unicorn_spec.rb` as part
of the build.

If you wish to make changes on the code generation script:

1. Add/modify a spec on `spec/templates/unicorn_spec.rb`
2. Add your new feature or change to `lib/templates/resource.ejs`
3. Run `rake` or, more granularly, `rake codegen && rspec
   spec/templates/unicorn_spec.rb`

Once you're sure your code works, submit a pull request and ask the maintainer
to make a release, as they'll need to run a release script from the
[asana-api-meta][meta] repository.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/asana/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[apidocs]: https://asana.com/developers
[io]: https://asana.com/developers/documentation/getting-started/input-output-options
[docs]: http://www.rubydoc.info/github/Asana/ruby-asana/master
[meta]: https://github.com/asana/asana-api-meta
