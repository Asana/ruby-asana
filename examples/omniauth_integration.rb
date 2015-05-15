require 'bundler'
Bundler.require
require 'asana'

class SinatraApp < Sinatra::Base
  id, secret = ENV['ASANA_CLIENT_ID'], ENV['ASANA_CLIENT_SECRET']
  unless id && secret
    abort "Run this program with the env vars ASANA_CLIENT_ID and ASANA_CLIENT_SECRET.\n"  \
      "Refer to https://asana.com/developers/documentation/getting-started/authentication "\
      "to get your credentials."
  end

  use OmniAuth::Strategies::Asana, id, secret

  enable :sessions

  get '/' do
    if $client
      '<a href="/workspaces">My Workspaces</a>'
    else
      '<a href="/sign_in">sign in to asana</a>'
    end
  end

  get '/workspaces' do
    if $client
      "<h1>My Workspaces</h1>" \
        "<ul>" + $client.workspaces.find_all.map { |w| "<li>#{w.name}</li>" }.join + "</ul>"
    else
      redirect '/sign_in'
    end
  end

  get '/auth/:name/callback' do
    creds = request.env["omniauth.auth"]["credentials"].tap { |h| h.delete('expires') }
    strategy = request.env["omniauth.strategy"]
    access_token = OAuth2::AccessToken.from_hash(strategy.client, creds).refresh!
    $client = Asana::Client.new do |c|
      c.authentication :oauth2, access_token
    end
    redirect '/workspaces'
  end

  get '/sign_in' do
    redirect '/auth/asana'
  end

  get '/sign_out' do
    $client = nil
    redirect '/'
  end
end

SinatraApp.run! if __FILE__ == $0
