module Rack
  module DoorCode
    
    class RestrictedAccess
      
      def initialize app, areas={}
        @app = app
        # Set the default code if no code is given
        @default_code = areas.delete(:code) || '12345'
        # Set a default area when no areas are supplied
        areas = {'default' => [/.+/, @default_code]} if areas.empty?
        # Set up available areas
        @areas = areas.map {|title, args| ::Rack::DoorCode::RestrictedArea.new(title, *args) }
      end
      
      # Rack::Request wrapper around @env
      def request
        @request ||= Rack::Request.new(@env)
      end
      
      # Rack::Response object with which to respond with
      def response
        @response ||= Rack::Response.new
      end
      
      # Is the request verb POST
      def post?
        request.request_method == 'POST'
      end
      
      # Was the request called via AJAX
      def xhr?
        @env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
      end
      
      # Path of request to match against
      def path
        @path ||= Rack::Utils.unescape(request.path_info)
      end
      
      # The extension used by request so we can render correct Content-Type
      def ext
        @ext ||= path.split('.').size > 1 ? path.split('.')[-1] : 'html'
      end
      
      # Content-Type of the request
      def mime_type
        @mime_type ||= Rack::Mime.mime_type(".#{ext}")
      end
      
      # Code supplied from user
      def supplied_code
        @supplied_code ||= request.params['code'].gsub(/(\D|0)/i)
      end
      
      # Current area for the request's path
      def area
        @area ||= @areas.detect {|c| c.matches_path? path }
      end
      
      # Is the supplied code vaid for the current area
      def valid_code?
        area.valid_code? supplied_code
      end
      
      # Check if the supplied code is valid;
      # Either sets a confirming cookie and Success message
      # or delete any door code cookie and set Failure message
      def validate_code!
        valid_code? ? confirm! : unconfirm!
      end
      
      # Unique cookie name for current area
      def cookie_name
        "door_code_#{area.title}"
      end
      
      # Is there a valid code for the area set in the cookie
      def confirmed?
        request.cookies[cookie_name] && area.valid_code?(request.cookies[cookie_name])
      end
      
      # Set a cookie for the correct value (server calue may change)
      # Also set up Success message
      def confirm!
        response.write 'Success'
        response.set_cookie(cookie_name, {:value => supplied_code, :path => "/"})
      end
      
      # Delete and invalid cookies
      # Also set up Failure message
      def unconfirm!
        response.write 'Failure'
        response.delete_cookie(supplied_code)
      end
      
      # Executed on every request
      def call env
        @env = env
        # Call app if no area or already confirmed
        return @app.call(env) if !area || confirmed?
        
        if post? # When request is a POST
          if xhr? # and request was called via AJAX
            # Make sure we're returning the correct Content-Type for AJAX
            response['Content-Type'] = 'text/javascript'
            validate_code! # Validate the user's code and set a cookie if valid
          else # request is not AJAX - need to redirect
            response.write 'Redirecting'
            response.redirect path, 301
          end
        else # Anything other than a POST request
          # Set the correct Content-Type of respond with
          response["Content-Type"] = mime_type
          begin
            # Find the DoorCode body content
            response.write ::File.read(::File.dirname(__FILE__) + 'index.' + ext)
          rescue # File not found - simply returns basic 404 (need to enhance this)
            response.write '404!'
            response.status = 404
          end
        end
        
        # Render response
        return response.finish
      end
      
    end
    
    # Individual area governed by a path string or regular expression, containing many valid codes
    class RestrictedArea
      attr_reader :title, :path_string_or_regexp, :valid_codes
      def initialize title, path_string_or_regexp, *valid_codes
        @title, @path_string_or_regexp, @valid_codes = title, path_string_or_regexp, valid_codes.flatten.compact
      end
      
      # Does the supplied path match the area's path requirements
      def matches_path? path
        if path_string_or_regexp.is_a?(Regexp)
          !(path_string_or_regexp =~ path).nil?
        else
          path_string_or_regexp == path
        end
      end
      
      # Is the supplied code included in the valid_codes
      def valid_code? code
        valid_codes.include? code
      end
    end
    
  end

end
