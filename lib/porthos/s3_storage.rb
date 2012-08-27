module Porthos

  mattr_accessor :s3_storage

  class S3Storage

    attr_accessor :bucket_name,
                  :access_key_id,
                  :secret_access_key

    def initialize(options)
      options.to_options.each do |key, value|
        send("#{key.to_s}=", value) if respond_to?("#{key.to_s}=")
      end
    end

    def store(source, target)
      file = bucket.objects.build(target)
      file.content = source
      if source.respond_to?(:original_filename)
        file.content_type = resolve_mime_type(source.original_filename)
        file.content_disposition = make_content_disposition source.original_filename
      end
      file.save
    end

    def details(key)
      bucket.objects.find(key)
    end

    def url(key)
      "http://#{bucket_name}.s3.amazonaws.com/#{key}"
    end

    def exists?(key)
      begin
        bucket.objects.find(key)
        true
      rescue ::S3::Error::NoSuchKey
        false
      end
    end

    def destroy(key)
      file = bucket.objects.find(key)
      file ? file.destroy : false
    end

  protected

    def resolve_mime_type(filename)
      MIME::Types.type_for(filename).first.to_s
    end

    def make_content_disposition(filename)
      extension = File.extname(filename).gsub(/\./,'').gsub(/\?.*/,'').downcase

      if Asset.filetypes[:image].include?(extension)
        "inline; filename=\"#{filename}\""
      else
        "attachment; filename=\"#{filename}\""
      end
    end

    def bucket
      @bucket ||= service.buckets.find(bucket_name).tap do |bucket|
        bucket.save(:location => 'eu') unless bucket.exists?
      end
    end

    def service
      @service ||= S3::Service.new({
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key
      })
    end

  end
end
