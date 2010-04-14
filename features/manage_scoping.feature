Feature: Manage scoping
  In order to allow users to register scopes that are not dependent on order (limit of fakeweb)
  As a user
  I want to be able to manage scopes

Scenario: Store responses in reverse order
  # Seems to be an error with fakeweb that keeps it from re-registering a url after clearing the registry - so I'm using google.com here instead of example.com
  Given caching is turned on
  And a clear cache
  And I scope the request to "first scope"
  And I visit "http://www.google.com"
  And I scope the request to "second scope"
  And I wait 3 seconds
  And I visit "http://www.google.com"
  And I save the cache
  And I have registered "second scope"
  And I visit "http://www.google.com"
  Given I have registered "first scope"
  And I visit "http://www.google.com"
  Then the first response should be later than the second