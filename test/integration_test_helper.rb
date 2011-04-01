require_relative 'test_helper'
require "capybara/rails"
require 'database_cleaner'
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css
DatabaseCleaner.strategy  = :truncation
Capybara.app = Dummy::Application
module ActionController
  class IntegrationTest
    include Capybara
    self.use_transactional_fixtures = false
  end
end