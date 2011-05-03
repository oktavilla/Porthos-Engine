class StringField < Field
  key :multiline, Boolean, :default => lambda { false }
  key :allow_rich_text, Boolean, :default => lambda { false }

  def datum_type
    DatumAttribute
  end
end