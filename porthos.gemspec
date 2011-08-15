# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'porthos/version'
Gem::Specification.new do |s|
  s.name     = 'porthos'
  s.version  = Porthos::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.authors  = ['Joel Junström', 'Arvid Andersson', 'Alexis Fellenius']

  s.summary     = 'A minimal CMS engine for Ruby On Rails projects'
  s.description = 'A minimal CMS engine for Ruby On Rails projects'
  s.files       = Dir['{app,public,lib,config}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'Gemfile', 'README.rdoc']

  s.required_rubygems_version = '~> 1.3.6'

  s.add_dependency 'rails', '3.1.0.rc5'

  # Asset pipeline
  s.add_dependency 'sass-rails', "~> 3.1.0.rc"
  s.add_dependency 'coffee-rails', "~> 3.1.0.rc"
  s.add_dependency 'uglifier'
  s.add_dependency 'jquery-rails'

  # Mongo
  s.add_dependency 'bson_ext'
  s.add_dependency 'mongo_mapper'
  s.add_dependency 'mongo_mapper_tree'
  s.add_dependency 'mm-multi-parameter-attributes'

  # Authentication
  s.add_dependency 'bcrypt-ruby'
  s.add_dependency 'warden'

  # Utilities
  s.add_dependency 'delayed_job'
  s.add_dependency 'has_scope', '~> 0.5.1'
  s.add_dependency 'routing-filter'
  s.add_dependency 's3'
  s.add_dependency 'resizor', '~> 0.0.9'
  s.add_dependency 'kaminari'
  s.add_dependency 'tanker'
  s.add_dependency 'stringex'

  # Dev dependencies
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'mongo-rails-instrumentation', '~> 0.2'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'capybara', '~> 1.0.1'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'addressable', '2.2.4'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
end