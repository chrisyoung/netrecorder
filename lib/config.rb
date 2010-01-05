# Config class is used to capture configuration options
module NetRecorder
  class Config
    # set to true to record net requests and responses to the cache file
    attr_accessor :record_net_calls
    # set to true to use fakeweb and the cache
    attr_accessor :fakeweb
    # path to the cache file
    attr_accessor :cache_file
    # clear the cache
    attr_accessor :clear_cache
  end
end