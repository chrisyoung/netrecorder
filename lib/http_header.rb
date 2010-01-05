# Override Net:HTTP_Header to capture basic auth
module NetRecorder
  module NetHTTPHeader
    def self.extended(base) #:nodoc:
      base.class_eval do
        alias :alias_for_basic_auth :basic_auth
        attr_accessor :bauth
        
        # override basic auth to make grabbing the basic auth easy
        def basic_auth(account, password)
          @bauth = "#{account}:#{password}@"
          alias_for_basic_auth(account, password)
        end
      end
    end
  end
end