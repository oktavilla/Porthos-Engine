# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rails/test_help'
require 'factory_girl'
require 'shoulda'
require File.dirname(__FILE__) + "/factories.rb"
require 'webmock/test_unit'
require "capybara/rails"
require 'mongo_mapper'
require 'database_cleaner'
require 'bcrypt'
require 'has_scope'
require 'porthos/test_helpers/assets_test_helper'

WebMock.allow_net_connect!

Capybara.default_driver   = :rack_test
Capybara.default_selector = :css
Capybara.app = Dummy::Application
Capybara.javascript_driver = :selenium

DatabaseCleaner[:mongo_mapper].strategy = :truncation

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


class ActiveSupport::TestCase
  include PorthosAssetTestHelpers

  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end
