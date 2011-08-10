# Replace with your S3 details
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
    tanking.index_name = "#{Rails.env}_#{Porthos.app_name}".downcase
    tanking.private_url = ''
  end
end
# We need to set this directly on the app conf for now
PorthosDevelopment::Application.config.index_tank_url = Porthos.config.tanking.private_url