class StringFieldTemplate < FieldTemplate
  key :multiline, Boolean, :default => lambda { false }
  key :allow_rich_text, Boolean, :default => lambda { false }
end