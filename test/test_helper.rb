# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rails/test_help'
require 'factory_girl'
require 'shoulda'
require File.dirname(__FILE__) + "/factories.rb"
require 'webmock/test_unit'
require "capybara/rails"
require 'mongo_mapper'
require 'database_cleaner'
require 'bcrypt'
require 'has_scope'

WebMock.allow_net_connect!

Capybara.default_driver   = :rack_test
Capybara.default_selector = :css
Capybara.app = Dummy::Application

DatabaseCleaner[:mongo_mapper].strategy = :truncation

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module PorthosTestHelpers
  def new_tempfile(type = 'image')
    path = File.join(Porthos.root, 'test', 'files')
    file = case type
    when 'image' then 'image.jpg'
    when 'text'  then 'page.txt'
    end

    tempfile = Tempfile.new(Time.now.to_s)
    tempfile.write IO.read(File.join(path, file))
    tempfile.rewind
    uploaded_file = ActionDispatch::Http::UploadedFile.new(:filename => file, :tempfile => tempfile)
    uploaded_file
  end

  def stub_resizor_post
    stub_http_request(:post, "https://resizor.com:443/assets.json").with { |request|
      request.body.include?("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg")
    }.to_return(:status => 201, :body => '{"asset": { "id":1, "name":"i", "extension":"jpg", "mime_type":"image/jpeg", "height":500, "width":332, "file_size":666, "created_at":"2010-10-23T13:07:25Z"}}')
  end

  def stub_resizor_delete
    stub_http_request(:delete, "https://resizor.com:443/assets/1.json?api_key=test-api-key").to_return(:status => 200)
  end

  def stub_s3_put
    stub_request(:put, /\.s3\.amazonaws\.com/).to_return(:status => 200, :headers => {
      'x-amz-id-2' => '123',
      'x-amz-request-id' => '0A49CE4060975EAC',
      'x-amz-version-id' => '43jfkodU8493jnFJD9fjj3HHNVfdsQUIFDNsidf038jfdsjGFDSIRp',
      'ETag' => "fbacf535f27731c9771645a39863328",
      'Content-Length' => '3200',
      'Server' => 'AmazonS3'
    })
  end

  def stub_s3_delete
    stub_request(:delete, /\.s3\.amazonaws\.com/).to_return(:status => 200, :headers => {
      'x-amz-delete-marker' => 'true',
      'x-amz-request-id' => '0A49CE4060975EAC',
      'x-amz-version-id' => '43jfkodU8493jnFJD9fjj3HHNVfdsQUIFDNsidf038jfdsjGFDSIRp',
      'ETag' => "fbacf535f27731c9771645a39863328",
      'Content-Length' => '0',
      'Server' => 'AmazonS3'
    })
  end

  def stub_s3_get
    stub_request(:get, /\.s3\.amazonaws\.com/).to_return(:status => 200, :body => '11223344556677889900', :headers => {
      'x-amz-request-id' => '0A49CE4060975EAC',
      'x-amz-version-id' => '43jfkodU8493jnFJD9fjj3HHNVfdsQUIFDNsidf038jfdsjGFDSIRp',
      'ETag' => "fbacf535f27731c9771645a39863328",
      'Content-Length' => '20',
      'Content-Type' => 'image/jpeg',
      'Server' => 'AmazonS3'
    })
  end

  def stub_s3_head
    stub_request(:head, /\.s3\.amazonaws\.com/).to_return(:status => 200, :body => '11223344556677889900', :headers => {
      'x-amz-request-id' => '0A49CE4060975EAC',
      'x-amz-version-id' => '43jfkodU8493jnFJD9fjj3HHNVfdsQUIFDNsidf038jfdsjGFDSIRp',
      'ETag' => "fbacf535f27731c9771645a39863328",
      'Content-Length' => '20',
      'Content-Type' => 'image/jpeg',
      'Server' => 'AmazonS3'
    })
  end

end

class ActiveSupport::TestCase
  include PorthosTestHelpers
end
