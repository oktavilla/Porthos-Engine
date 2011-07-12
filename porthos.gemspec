# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = 'porthos'
  s.summary = 'Insert Porthos summary.'
  s.description = 'Insert Porthos description.'
  s.files = Dir['{app,public,lib,config}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'Gemfile', 'README.rdoc']
  s.version = '0.0.1'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'rails', '3.1.0.rc4'

  # Asset pipeline
  s.add_dependency 'sass'
  s.add_dependency 'coffee-script', '2.2.0'
  s.add_dependency 'uglifier'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'sprockets', '2.0.0.beta.10'

  # Mongo
  s.add_dependency 'bson_ext'
  s.add_dependency 'mongo_mapper'
  s.add_dependency 'ramdiv-mongo_mapper_acts_as_tree'
  s.add_dependency 'mm-multi-parameter-attributes'

  # Authentication
  s.add_dependency 'bcrypt-ruby'
  s.add_dependency 'warden'

  # Utilities
  s.add_dependency 'delayed_job'
  s.add_dependency 'has_scope'
  s.add_dependency 'routing-filter'
  s.add_dependency 's3'
  s.add_dependency 'resizor', '>=0.0.9'
  s.add_dependency 'kaminari'
  s.add_dependency 'tanker'
  s.add_dependency 'stringex'

  # Dev dependencies
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'mongo-rails-instrumentation', '~>0.2'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'capybara', '~>1.0'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'addressable', '2.2.4' # 2.2.5 (lastest version) seem to break webmock
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
end
