class FieldSet < Datum
  key :template, String

  many :data do
    def [](handle)
      detect { |d| d.handle == handle.to_s }
    end
  end

  class << self
    def from_template(template)
      FieldSet.new(:attributes => template.shared_attributes.except(:field_templates)).tap do |field_set|
        field_set.data = template.field_templates.collect do |t|
          Field.from_template(t)
        end
      end
    end
  end
end