# NetRecorder allows you to record requests and responses from the web

require 'fakeweb'
require "#{File.dirname(__FILE__)}/http"
require "#{File.dirname(__FILE__)}/http_header"
require "#{File.dirname(__FILE__)}/config"

# NetRecorder - the global namespace
module NetRecorder
  
  # the path to the cache file
  def self.cache_file
    @@config.cache_file
  end
  
  # configure netrecorder
  def self.config
    @@config = Config.new
    yield @@config
    clear_cache!      if @@config.clear_cache
    fakeweb           if @@config.fakeweb
    record_net_calls  if @@config.record_net_calls
  end
  
  # returns true if record_net_calls is set to true in the config
  def self.recording?
    @@config.record_net_calls
  end
    
  # save the fakes hash to the cash file
  def self.cache!
    File.open(@@config.cache_file, 'w') {|f| f.write Net::HTTP.fakes.to_yaml}
  end
  
  # delete the cache file
  def self.clear_cache!
    if File.exist?(@@config.cache_file)
      File.delete(@@config.cache_file)
    end
  end
  
private
  # load the cache and register all of the urls with fakeweb
  def self.fakeweb
    fakes = File.open(@@config.cache_file, "r") do |f|
       YAML.load(f.read)
    end

    fakes.each do |method, value|
      value.each do |url, body|
        path = url
        FakeWeb.register_uri(method.downcase.to_sym, url, body)
      end
    end
  end
  
  # extend NET library to record requests and responses
  def self.record_net_calls
    Net::HTTP.extend(NetHTTP)
    Net::HTTPHeader.extend(NetHTTPHeader)
  end
end