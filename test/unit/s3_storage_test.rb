require_relative '../test_helper'

class S3StorageTest < ActiveSupport::TestCase

  context 'A S3Storage helper class' do

    setup do
      WebMock.disable_net_connect!
      @s3_storage = Porthos::S3Storage.new({
        :bucket_name => 'my-bucket',
        :access_key_id => 'abc',
        :secret_access_key => '123'
      })
    end

    should 'setup credentials on initialize' do
      assert_equal 'my-bucket', @s3_storage.bucket_name
      assert_equal 'abc', @s3_storage.access_key_id
      assert_equal '123', @s3_storage.secret_access_key
    end

    should 'resolve mime type for a filename' do
      assert_equal 'image/jpeg', @s3_storage.send(:resolve_mime_type, 'image.jpg')
    end

    should 'store file' do
      stub_s3_head
      stub_s3_put
      @s3_storage.store(new_tempfile('text'), 'my-file.txt')

      assert_requested :put, 'http://my-bucket.s3.amazonaws.com/my-file.txt?'
    end

    should 'retrieve details for file' do
      stub_s3_head
      @s3_storage.details('my-file.txt')
      assert_requested :head, 'http://my-bucket.s3.amazonaws.com/my-file.txt?'
    end

    should 'generate url for file' do
      assert_equal 'http://my-bucket.s3.amazonaws.com/my-file.txt', @s3_storage.url('my-file.txt')
    end

    context 'knwo if a file exists on s3' do
      should 'return true if it exists' do
        stub_s3_head
        assert @s3_storage.exists?('my-file.txt')
      end

      should 'return false if it doesn\'t exist' do
        stub_s3_head # for bucket
        stub_request(:head, 'http://my-bucket.s3.amazonaws.com/my-file.txt?').to_return(:status => 404)
        refute @s3_storage.exists?('my-file.txt')
      end
    end

    should 'delete a file on s3' do
      stub_s3_head
      stub_s3_delete
      @s3_storage.destroy('my-file.txt')
      assert_requested :delete, 'http://my-bucket.s3.amazonaws.com/my-file.txt?'
    end

  end
end
