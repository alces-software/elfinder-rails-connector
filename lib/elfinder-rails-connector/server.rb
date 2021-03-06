#==============================================================================
# Copyright (C) 2012 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails-connector.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================
require 'rack/request'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

module ElfinderRailsConnector
  class Server
    def initialize(opts = {})
      Configuration.config_file = opts[:config_file]
      Configuration.environment = opts[:environment]
      @origins = opts[:origins] || '*'
    end

    class << self
      def run(opts = {})
        Rack::Chunked.new(Rack::ContentLength.new(ElfinderRailsConnector::Server.new(opts)))
      end
    end

    module Base
      # `call` implements the Rack 1.x specification which accepts an
      # `env` Hash and returns a three item tuple with the status code,
      # headers, and body.
      def call(env)
        # Mark session as "skipped" so no `Set-Cookie` header is set
        env['rack.session.options'] ||= {}
        env['rack.session.options'][:defer] = true
        env['rack.session.options'][:skip] = true
        
        params = Rack::Request.new(env).params.symbolize_keys!
        ctx = Context.new(env,params)
        data = Arriba::execute(ElfinderRailsConnector.volumes(ctx),params)
        handle_data(env,data)
      rescue
        begin
          STDERR.puts "ERROR: #{$!.message}\n#{$!.backtrace.join("\n")}"
          # error responses are returned as 200 responses so elfinder
          # can present the error condition to the user
          ok_response({:error => $!.message}.to_json,headers)
        rescue
          # finally fallback to 500 error
          STDERR.puts "ERROR: #{$!.message}\n#{$!.backtrace.join("\n")}"
          [500, {'Content-Type' => 'text/plain'}, ["Error: #{$!.message}"]]
        end
      end
      
      def headers
        {
          'Access-Control-Allow-Origin' => @origins,
          'Content-Type' => 'application/json'
        }
      end

      def handle_data(env,data)
        case data
        when Hash
          ok_response(data.to_json,headers)
        when Arriba::FileResponse
          h = headers.tap do |hash|
            hash.delete('Content-Type')
            hash.merge!(ElfinderRailsConnector.file_headers(data,env))
          end
          # convince rails middleware stack to get lost and leave our
          # streamable content as streamable content (no etag)
          # XXX - generate our own etag?
          h['Cache-Control'] = 'no-cache'
          h['Content-Length'] = data.length.to_s unless data.length.nil?
          ok_response(data.io, h)
        else
          ok_response({:error => "Unsupported data type: #{data.class.name}"}.to_json,headers)
        end
      end

      private
      # Returns a 200 OK response tuple
      def ok_response(body, headers = {})
        body = [body] unless body.respond_to?(:each)
        [ 200, headers, body ]
      end
    end
    include Base
  end
end
