require 'rails/generators/migration'

class PorthosGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.new.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    migration_template 'porthos_migration.rb', 'db/migrate/create_porthos_tables.rb'
    copy_file 'seeds.rb', 'db/porthos_seeds.rb'
    copy_file 'porthos.rb', 'config/initializers/porthos.rb'
    copy_file 'mongo.yml', 'config/mongo.yml'
  end
end
