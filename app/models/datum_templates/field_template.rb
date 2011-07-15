class FieldTemplate < DatumTemplate
  key :input_type, String

  cattr_reader :input_types
  @@input_types = ['string', 'date', 'boolean']
end