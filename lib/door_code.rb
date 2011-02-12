module Rack
  module DoorCode
    class RestrictedAccess
      
      def initialize app, options={}
        @app = app  
        @code = options[:code].to_s
        # @domains = options[:domains]
        
        check_code
      end
      
      def check_code
        parsed_code = @code.gsub(/(\D|0)/i)
        @code = '12345' unless @code == parsed_code
      end
  
      # Where the magic happens...
      def call env
        @env = env
        # Set up the session
        # Build the request object for inspection
        request = Rack::Request.new(env)
        # Is it a GET? POST? Other?
        verb = request.request_method
        # Where is this request going?
        path = Rack::Utils.unescape(request.path_info)
        # What type of resource is the request fetching?
        # If no format is given, assume it's text/html (and that it's /index.html)
        ext = path.split('.').size > 1 ? path.split('.')[-1] : 'html'
        path = "#{path}index.html" if ext == 'html'
        mime = Rack::Mime.mime_type(".#{ext}")
          
        if verb == "POST"
          ajax = env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
          # Validation time!
          # If the code is confirmed, halt the request and reload as a GET request
          # This will catch the session and call the app
          # *This is to reset the method from POST to GET, as Rails requires
          # an authenticity token for all POST requests
          if request.params['code'] == @code
            @confirmed = 'true'
            status, headers, response = 301, {"Location" => '/'}, [] if !ajax
            status, headers, response = 200, {"Content-Type" => 'text/javascript'}, ['true'] if ajax
          else
            @confirmed = nil
            status, headers, response = 403, {"Content-Type" => 'text/javascript'}, ['false'] if ajax
          end
        end
    
        if @confirmed == 'true'
          # This means the user has already confirmed the code, so
          # we proceed to the app
          status, headers, response = @app.call(env)
        else
          # Otherwise, we fetch the resource using this file (door_code.rb) as the root
          begin
            file = ::File.read(::File.dirname(__FILE__) + path)
            status, headers, response = 200, {"Content-Type" => mime}, [file]
          rescue # File not found - simply returns basic 404 (need to enhance this)
            not_found(mime)
          end
        end
        
        [status, headers, response]
      end
  
      def not_found mime
        status, headers, response = 404, {"Content-Type" => mime}, ["404!"]
      end
      
    end
  end
end