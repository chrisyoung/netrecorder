Feature: Manage cache
  In order to speed up my testing and avoid network calls
  As a user
  I want to be able to manage the cache

Scenario: Cache a page
  Given caching is turned on
  And a clear cache
  When I visit "http://www.example.com"
  And I save the cache
  Then the cache should contain the example body

Scenario: Cache a page with a Net::HTTP request with a block
  Given caching is turned on
  And a clear cache
  When I visit "http://www.example.com" using a  Net::HTTP request with a block
  And I save the cache
  Then the cache should contain the example body
  And the Net::HTTP request should return the response

Scenario: Clear the cache
  Given caching is turned on
  Given a clear cache
  And a cached example page
  When I delete the cache
  Then the cache should be empty
  
Scenario: Cache the same page twice
  Given caching is turned on
  And a clear cache
  When I visit "http://www.example.com"
  When I visit "http://www.example.com"
  And I save the cache
  Then the example entry should have 2 responses

Scenario: Load from a cache
  Given caching is turned on
  Given a clear cache
  And a cached example page
  And I have turned on fakeweb
  Then I should not hit the web if i visit the example page
