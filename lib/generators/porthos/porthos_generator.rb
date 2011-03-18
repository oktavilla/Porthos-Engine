require 'rails/generators/active_record'

class PorthosGenerator < ActiveRecord::Generators::Base
  desc "Create a mmigration to add create porthos tables"

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def generate_migration
    migration_template "porthos_migration.rb.erb", "db/migrate/#{migration_file_name}"
  end

  protected

  def migration_name
    "create_porthos_tables"
  end

  def migration_file_name
    "#{migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end

end
