class DatumTemplate
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  key :instructions, String

  def datum_class
    (self.class.ancestors - self.class.included_modules).collect do |klass|
      klass.to_s.gsub('Template', '')
    end.detect do |klass_name|
      begin
        defined?(klass_name.constantize)
      rescue NameError
        false
      end
    end
  end

  def shared_attributes
    attributes.clone.except(:_id, :_type, :instructions).inject({}) do |hash, entry|
      key, value = entry
      hash[key] = value.duplicable? ? value.clone : value
      hash
    end
  end

end