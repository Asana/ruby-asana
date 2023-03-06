# frozen_string_literal: true

require_relative '../version'
require 'openssl'

module Asana
  class HttpClient
    # Internal: Adds environment information to a Faraday request.
    class EnvironmentInfo
      # Internal: The default user agent to use in all requests to the API.
      USER_AGENT = "ruby-asana v#{Asana::VERSION}"

      def initialize(user_agent = nil)
        @user_agent = user_agent || USER_AGENT
        @openssl_version = OpenSSL::OPENSSL_VERSION
        @client_version = Asana::VERSION
        @os = os
      end

      # Public: Augments a Faraday connection with information about the
      # environment.
      def configure(builder)
        builder.headers[:user_agent] = @user_agent
        builder.headers[:'X-Asana-Client-Lib'] = header
      end

      private

      def header
        { os: @os,
          language: 'ruby',
          language_version: RUBY_VERSION,
          version: @client_version,
          openssl_version: @openssl_version }
          .map { |k, v| "#{k}=#{v}" }.join('&')
      end

      def os
        case RUBY_PLATFORM
        when /win32/, /mingw/
          'windows'
        when /linux/
          'linux'
        when /darwin/
          'darwin'
        when /freebsd/
          'freebsd'
        else
          'unknown'
        end
      end
    end
  end
end
