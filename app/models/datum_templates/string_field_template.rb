class StringFieldTemplate < FieldTemplate
  key :multiline, Boolean, default: -> { false }
  key :allow_rich_text, Boolean, default: -> { false }
end
