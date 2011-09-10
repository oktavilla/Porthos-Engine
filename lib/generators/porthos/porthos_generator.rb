class PorthosGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def application_name
    Rails.application.class.name.split('::').first
  end

  def create_initializer_file
    initializer 'porthos.rb', <<-FILE
Porthos.s3_storage = Porthos::S3Storage.new({
  :bucket_name => "porthos-assets",
  :access_key_id => '',
  :secret_access_key => ''
})

Porthos.configure do |config|
  config.observers = :node_observer

  config.resizor do |resizor|
    resizor.api_key = ''
  end

  config.tanking do |tanking|
    tanking.index_name = "#{Rails.env}_#{application_name.underscore}".downcase
    tanking.private_url = ''
  end
end
#{application_name}::Application.config.index_tank_url = Porthos.config.tanking.private_url
    FILE
  end

  def create_config_file
    copy_file 'mongo.yml', 'config/mongo.yml'
  end
end
