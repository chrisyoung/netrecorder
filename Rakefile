require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('netrecorder', '0.2.0') do |p|
  p.description    = "Record network responses for easy stubbing of external calls"
  p.url            = "http://github.com/chrisyoung/netrecorder"
  p.author         = "Chris Young"
  p.email          = "beesucker@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = %w(echoe cucumber rspec)
  p.runtime_dependencies = %w(fakeweb)
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
