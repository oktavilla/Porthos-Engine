class ContentTemplate < Template
  def to_datum
    FieldSet.new.tap do |field_set|
      field_set.attributes = self.shared_attributes
      field_set.data = self.datum_templates.map { |t| t.to_datum }
    end
  end

  def shared_attributes
    { :label => self.label }
  end
end