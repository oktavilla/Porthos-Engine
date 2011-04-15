# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "porthos"
  s.summary = "Insert Porthos summary."
  s.description = "Insert Porthos description."
  s.files = Dir["{app,public,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = "0.0.1"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "bundler"
  s.add_dependency "rails", "3.0.6"
  s.add_dependency "routing-filter"
  s.add_dependency "mime-types"
  s.add_dependency "mini_magick"
  s.add_dependency "will_paginate"
  s.add_dependency 'sunspot_rails'
  s.add_dependency 'delayed_job'
  s.add_dependency 'sunspot'
  s.add_dependency 'has_scope'
  s.add_dependency 'parndt-acts_as_tree'
  s.add_dependency 's3'
  s.add_dependency 'resizor'
  s.add_dependency 'oktavilla-resort'
  s.add_dependency 'bson_ext'
  s.add_dependency 'mongo_mapper'

  # Dev dependencies
  s.add_dependency 'shoulda'
  s.add_dependency 'factory_girl'
  s.add_dependency 'redgreen'
  s.add_dependency 'cucumber'
  s.add_dependency 'cucumber-rails'
  s.add_dependency 'capybara'
  s.add_dependency 'database_cleaner'
  s.add_dependency 'rack-test'
  s.add_dependency 'sqlite3'
  s.add_dependency 'webmock'
end
