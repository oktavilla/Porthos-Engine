class StringAttribute < DatumAttribute
  key :multiline, Boolean, :default => lambda { false }
  key :allow_rich_text, Boolean, :default => lambda { false }

protected

  def self.extract_field_attributes(field)
    {
      :input_type => field.class.model_name.gsub(/Field/, '').underscore,
      :multiline => field.multiline?,
      :allow_rich_text => field.allow_rich_text?
    }
  end

end