# NetRecorder allows you to record requests and responses from the web

require 'fakeweb'
require 'yaml'
require "#{File.dirname(__FILE__)}/http"
require "#{File.dirname(__FILE__)}/http_header"
require "#{File.dirname(__FILE__)}/config"

# NetRecorder - the global namespace
module NetRecorder
  
  # the path to the cache file
  def self.cache_file
    @@config.cache_file
  end
  
  def self.fakes
    if File.exist?(@@config.cache_file)
      File.open(@@config.cache_file, "r") do |f|
        YAML.load(f.read)
      end
    end || []
  end
  
  # configure netrecorder
  def self.config
    @@configured ||= nil
    @@config = Config.new
    yield @@config
    record_net_calls
    clear_cache!      if @@config.clear_cache
    fakeweb           if @@config.fakeweb
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
    Net::HTTP.clear_netrecorder_cache!
  end

  def self.register_scope(name)
    fakeweb(name)
  end
  
  def self.scope=(name)
    @@scope = name
  end
  
  def self.scope
    return @@scope if defined?(@@scope) 
    'global'
  end
  
private
    
  # load the cache and register all of the urls with fakeweb
  def self.fakeweb(scope='global')
    fakes.each do |fake|
      if fake[1][scope]
        FakeWeb.register_uri(fake[1][scope][:method].downcase.to_sym, fake[0], fake[1][scope][:response]) 
      end
    end
  end
  
  # extend NET library to record requests and responses
  def self.record_net_calls
    return if @@configured
    @@configured = true
    
    Net::HTTP.extend(NetHTTP)
    Net::HTTPHeader.extend(NetHTTPHeader)
  end
end