require_relative "../../test_helper.rb"
ENV["RAILS_ROOT"] = File.expand_path("../../../dummy/",  __FILE__)

require 'capybara'
require 'cucumber/rails'
require 'pickle'

Capybara.default_driver   = :rack_test
Capybara.default_selector = :css
Capybara.app = Dummy::Application

ActionController::Base.allow_rescue = false
DatabaseCleaner.strategy = :truncation
