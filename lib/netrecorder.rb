require 'fakeweb'
require "#{File.dirname(__FILE__)}/http"
require "#{File.dirname(__FILE__)}/http_header"

module NetRecorder
  class Config
    attr_accessor :record_net_calls, :fakeweb, :cache_file
  end
  
  def self.config
    @@config = Config.new
    yield @@config
    fakeweb           if @@config.fakeweb
    record_net_calls  if @@config.record_net_calls
  end
  
  def self.recording?
    @@config.record_net_calls
  end
    
  def self.cache!        
    File.open(@@config.cache_file, 'w') {|f| f.write Net::HTTP.fakes.to_yaml}
  end
  
private 
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

  def self.record_net_calls
    Net::HTTP.extend(NetHTTP)
    Net::HTTPHeader.extend(NetHTTPHeader)
  end
end