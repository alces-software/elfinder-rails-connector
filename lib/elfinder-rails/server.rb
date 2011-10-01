require 'rack/request'
require 'json'

module ElfinderRails
  class Server
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
        data = Arriba::execute(ElfinderRails.volumes(ctx),params)
        handle_data(env,data)
      end
      
      def handle_data(env,data)
        case data
        when Hash
          ok_response(data.to_json,{'Content-Type' => 'application/json'})
        when Arriba::FileResponse
          headers = ElfinderRails.file_headers(data,env)
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
