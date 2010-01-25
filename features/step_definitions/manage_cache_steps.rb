require 'rubygems'
require 'fakeweb'
require "#{File.dirname(__FILE__)}/../../lib/netrecorder"

module NetRecorderMatchers
  def be_the_example_dot_com_response
    simple_matcher("the example.com response") do |given|
      given =~ /You have reached this web page by typing.*example\.com/
    end
  end
end

World(NetRecorderMatchers)

Then "caching is turned on" do
  NetRecorder.config do |config|
    config.cache_file = File.join(File.dirname(__FILE__), '..', 'support', 'cache')
    config.record_net_calls = true
  end
end

And /^I save the cache$/ do
  NetRecorder.cache!
end

And /^I visit "([^\"]*)"$/ do |url|
  Net::HTTP.get URI.parse(url)
end

When /^I visit "([^\"]*)" using a  Net::HTTP request with a block$/ do |url|
  uri = URI.parse(url)
  @last_response = Net::HTTP.new(uri.host, uri.port).start do |http|
    http.get(uri.path.empty? ? '/' : uri.path)
  end
end

Then /^the Net::HTTP request should return the response$/ do
  @last_response.should_not be_nil
  @last_response.body.should be_the_example_dot_com_response
end

Given /^(?:a clear cache|I delete the cache)$/ do  
  NetRecorder.clear_cache!
end

Then /^the cache should contain the example body$/ do
  NetRecorder.fakes.first[1]['global'][:response].first[:response].body.should be_the_example_dot_com_response
end

Given /^a cached example page$/ do
  Given "caching is turned on"
  When %Q{I visit "http://www.example.com"}
  And "I save the cache"
end

Then /^the cache should be empty$/ do
  NetRecorder.fakes.should == []
end

Then /^the example entry should have (.+) responses$/ do |count|
  NetRecorder.fakes.first[1]['global'][:response].length.should == count.to_i
end

Given /^I have turned on fakeweb$/ do
  NetRecorder.config do |config|
    config.cache_file = File.join(File.dirname(__FILE__), '..', 'support', 'cache')
    config.fakeweb = true
  end
end

Then /^I should not hit the web if i visit the example page$/ do
  FakeWeb.allow_net_connect = false
  Proc.new{Net::HTTP.get URI.parse('http://www.example.com/')}.should_not raise_error
end