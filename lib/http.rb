# Extend Net:HTTP to record requests and responses
module NetRecorder
  module NetHTTP
    def self.extended(base) #:nodoc:
      base.class_eval do
        alias :alias_for_request :request
        @@fakes = fakes_cache || init_netrecorder_cache

        # request is overridden and the request and response are stored as a hash that can be written to a cache file
        def request(req, body = nil, &block)
          response = alias_for_request(req, body)
          path = "http://#{req.bauth if req.bauth}#{req['host']}#{req.path}"
          if @@fakes[req.method][path]
            @@fakes[req.method][path] << {:body => response.body.to_s}
          else
            @@fakes[req.method][path] = [:body => response.body.to_s]
          end
          return response
        end
        
        # returns the fakes hash
        def self.fakes
          @@fakes
        end
        
        def self.clear_netrecorder_cache!
          @@fakes = init_netrecorder_cache
        end



        def init_netrecorder_cache
          self.class.init_netrecorder_cache
        end
        
      end
    end
  end
end

# Loads the yaml from the cache file and returns a hash
def fakes_cache
  fakes =
  if File.exist?(NetRecorder.cache_file)
    File.open(NetRecorder.cache_file, "r") do |f|
      YAML.load(f.read)
    end 
  end
  
  return fakes if fakes.class == Hash
  nil
end

def init_netrecorder_cache
  {'GET' => {}, 'POST' => {}, 'DELETE' => {}, 'PUT' => {}}
end
