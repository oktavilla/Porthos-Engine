# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
# Remove test database so we can run migrations
# silence_stream(STDOUT) do
`rm #{File.expand_path("../dummy/db/test.sqlite3",  __FILE__)}`
# end
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rails/test_help'
require 'factory_girl'
require 'shoulda'
require File.dirname(__FILE__) + "/factories.rb"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration (in silience)
silence_stream(STDOUT) do
  `cd #{Porthos.root.join('test')}/dummy; rm db/migrate/*_create_porthos_tables.rb;rails g porthos`
  ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
