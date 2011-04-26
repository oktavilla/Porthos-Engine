class AssociationField < Field
  key :relationship, String
  key :association_source_id, ObjectId
  belongs_to :association_source,
             :class_name => 'FieldSet'
end