Given /^I have registered "([^\"]*)"$/ do |scope|
  NetRecorder.register_scope(scope)
  FakeWeb.allow_net_connect = false
end

Then /^the first response should be later than the second$/ do
  first_date  = DateTime.parse(@last_response['date'])
  second_date = DateTime.parse(@response['date'])
  raise 'the first response is not more recent' if first_date < second_date
end

Given /^I scope the request to "([^\"]*)"$/ do |scope|
  NetRecorder.scope = scope
end

Given /^I wait (.+) seconds$/ do |count|
  sleep count.to_i
end