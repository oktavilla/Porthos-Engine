# Replace with your S3 details
Porthos.s3_storage = Porthos::S3Storage.new({
  :bucket_name => "porthos-assets",
  :access_key_id => '',
  :secret_access_key => ''
})
Porthos.config.tanking.index_name = "#{Rails.env}_#{Porthos.app_name}".downcase