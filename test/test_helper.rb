ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rails/test_help'
require 'factory_girl'
require 'shoulda'
require 'webmock/test_unit'
require 'mongo_mapper'
require 'database_cleaner'
require 'bcrypt'
require 'has_scope'
require 'porthos/test_helpers/assets_test_helper'
require 'porthos/test_helpers/searchify_stubs'
require 'capybara/rails'
require 'capybara-webkit'
require File.dirname(__FILE__) + '/factories.rb'

require 'mocha'

WebMock.allow_net_connect!

Capybara.default_driver   = :rack_test
Capybara.default_selector = :css
Capybara.app = Dummy::Application
Capybara.javascript_driver = :webkit

DatabaseCleaner[:mongo_mapper].strategy = :truncation

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:ost] = "test.com"

Tanker.configuration = {
  :pagination_backend => :kaminari,
  :url => 'http://test.api.searchify.com'
}

Delayed::Worker.delay_jobs = false

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

DatabaseCleaner.start
MiniTest::Unit.after_tests do
  WebMock.reset!
end

class ActiveSupport::TestCase
  include PorthosAssetTestHelpers
  include SearchifyStubs

  setup do
    WebMock.allow_net_connect!
    stub_searchify_put
    stub_searchify_delete
  end

  teardown do
    DatabaseCleaner.clean
  end
end
