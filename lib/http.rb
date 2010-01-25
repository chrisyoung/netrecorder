# Extend Net:HTTP to record requests and responses
module NetRecorder
  module NetHTTP
    def self.extended(base) #:nodoc:
      base.class_eval do
        alias :alias_for_request :request
        @@fakes = fakes_cache || []

        # request is overridden and the request and response are stored as a hash that can be written to a cache file
        def request(req, body = nil, &block)
          response = alias_for_request(req, body)
          
          return response unless NetRecorder.recording?
          
          scope = NetRecorder.scope || 'global'
          path = "http://#{req.bauth if req.bauth}#{req['host']}#{req.path}"
          
          existing_fake = @@fakes.detect{|fake| fake[0] == path && fake[1][scope] && fake[1][scope][:method] == req.method}
          existing_fake[1][scope][:response] << {:response => response} and return response if existing_fake
          
          @@fakes << [path, {scope => {:method => req.method, :response => [{:response => response}]}}]
          yield response if block
          response
        end
        
        # returns the fakes hash
        def self.fakes
          @@fakes
        end
        
        def self.clear_netrecorder_cache! #:nodoc:
          @@fakes = []
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