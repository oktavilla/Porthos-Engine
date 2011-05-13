class FieldSetTemplate < DatumTemplate
  key :content_template_id, ObjectId
  belongs_to :content_template

  def shared_attributes
    super.except(:content_template_id)
  end

end