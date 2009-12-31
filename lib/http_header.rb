module NetRecorder
  module NetHTTPHeader
    def self.extended(base)
      base.class_eval do
        alias :alias_for_basic_auth :basic_auth
        attr_accessor :bauth
        def basic_auth(account, password)
          @bauth = "#{account}:#{password}@"
          alias_for_basic_auth(account, password)
        end
      end
    end
  end
end