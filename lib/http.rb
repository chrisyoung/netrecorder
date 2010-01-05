# Extend Net:HTTP to record requests and responses
module NetRecorder
  module NetHTTP
    def self.extended(base)
      base.class_eval do
        alias :alias_for_request :request
        @@fakes = nil

        @@fakes = File.open(NetRecorder.cache_file, "r") do |f|
           YAML.load(f.read)
        end if File.exist?(NetRecorder.cache_file)
        @@fakes = {'GET' => {}, 'POST' => {}, 'DELETE' => {}, 'PUT' => {}} unless @@fakes && @@fakes.class == Hash
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
        
        def self.fakes
          @@fakes
        end
      end
    end
  end
end
