require 'rack/request'
require 'json'

module ElfinderRails
  class Server
    class << self
      def run
        Rack::Chunked.new(Rack::ContentLength.new(ElfinderRails::Server.new))
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
        session_id = (session = env['rack.session']) && session['session_id']
        ctx = Context.new(env,params,session_id)
        data = Arriba::execute(ElfinderRails.volumes(ctx),params)
        handle_data(env,data)
      rescue
        begin
          STDERR.puts "ERROR: #{$!.message}\n#{$!.backtrace.join("\n")}"
          # error responses are returned as 200 responses so elfinder
          # can present the error condition to the user
          ok_response({:error => $!.message}.to_json,{'Content-Type' => 'application/json'})
        rescue
          # finally fallback to 500 error
          STDERR.puts "ERROR: #{$!.message}\n#{$!.backtrace.join("\n")}"
          [500, {'Content-Type' => 'text/plain'}, ["Error: #{$!.message}"]]
        end
      end
      
      def handle_data(env,data)
        case data
        when Hash
          ok_response(data.to_json,{'Content-Type' => 'application/json'})
        when Arriba::FileResponse
          headers = ElfinderRails.file_headers(data,env)
          # convince rails middleware stack to get lost and leave our
          # streamable content as streamable content (no etag)
          # XXX - generate our own etag?
          headers['Cache-Control'] = 'no-cache'
          headers['Content-Length'] = data.length.to_s unless data.length.nil?
          ok_response(data.io, headers)
        else
          ok_response({:error => "Unsupported data type: #{data.class.name}"}.to_json,{'Content-Type' => 'application/json'})
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