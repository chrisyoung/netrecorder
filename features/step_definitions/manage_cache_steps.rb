require 'rubygems'
require 'fakeweb'
require "#{File.dirname(__FILE__)}/../../lib/netrecorder"

Then "caching is turned on" do
  NetRecorder.config do |config|
    config.cache_file = File.join(File.dirname(__FILE__), '..', 'support', 'cache')
    config.record_net_calls = true
  end
end

And /^I save the cache$/ do
  NetRecorder.cache!
end

And /^I visit "([^\"]*)"$/ do |arg1|
  Net::HTTP.get URI.parse('http://www.example.com/')
end

Given /^(?:a clear cache|I delete the cache)$/ do  
  NetRecorder.clear_cache!
end

Then /^the cache should contain the example body$/ do
  NetRecorder.fakes.first[1][:body].first[:body].should == 
%Q{<HTML>
<HEAD>
  <TITLE>Example Web Page</TITLE>
</HEAD> 
<body>  
<p>You have reached this web page by typing &quot;example.com&quot;,
&quot;example.net&quot;,
  or &quot;example.org&quot; into your web browser.</p>
<p>These domain names are reserved for use in documentation and are not available 
  for registration. See <a href="http://www.rfc-editor.org/rfc/rfc2606.txt">RFC 
  2606</a>, Section 3.</p>
</BODY>
</HTML>
}
end

Given /^a cached example page$/ do
  Given "caching is turned on"
  When %Q{I visit "http://www.example.com"}
  And "I save the cache"
end

Then /^the cache should be empty$/ do
  NetRecorder.fakes.should == nil
end

Then /^the example entry should have (.+) responses$/ do |count|
  NetRecorder.fakes.first[1][:body].length.should == count.to_i
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