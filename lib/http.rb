# Extend Net:HTTP to record requests and responses
module NetRecorder
  module NetHTTP
    def self.extended(base) #:nodoc:
      base.class_eval do
        alias :alias_for_request :request
        class_variable_set :@@fakes, fakes_cache || []

        # request is overridden and the request and response are stored as a hash that can be written to a cache file
        def request(req, body = nil, &block)
          response = alias_for_request(req, body)

          unless NetRecorder.recording?
            yield response and return if block
            return response
          end
          
          scope = NetRecorder.scope || 'global'
          path = "http://#{req.bauth if req.bauth}#{req['host']}#{req.path}"
          
          fakes = self.class.class_variable_get :@@fakes
          existing_fake = fakes.detect do |fake| 
            fake[Fake::REQUEST] == path && 
            fake[Fake::RESPONSE][scope] && 
            fake[Fake::RESPONSE][scope][:method] == req.method
          end
          
          if existing_fake
            existing_fake[Fake::RESPONSE][scope][:response] << {:response => response}
          else
            fakes << [path, {scope => {:method => req.method, :response => [{:response => response}]}}]
          end

          yield response if block
          response
        end
        
        # returns the fakes hash
        def self.fakes
          class_variable_get :@@fakes
        end
        
        def self.clear_netrecorder_cache! #:nodoc:
          class_variable_set :@@fakes, []
        end
      end
    end
  end
end


def fakes_cache #:nodoc:
  fakes =
  if File.exist?(NetRecorder.cache_file)
    File.open(NetRecorder.cache_file, "r") do |f|
      YAML.load(f.read)
    end
  end
  
  return fakes if fakes.class == Hash
  nil
end
