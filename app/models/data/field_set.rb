class FieldSet < Datum
  key :template, String

  many :data do
    def [](handle)
      detect { |d| d.handle == handle.to_s }
    end
  end

  def data_attributes=(datum_array)
    self.data = datum_array.map do |i, attrs|
      attrs.to_options!
      if id = attrs.delete(:id)
        unless attrs[:_destroy]
          data.detect { |d| d.id.to_s == id }.tap do |datum|
            datum.assign(attrs) if attrs.keys.any?
          end
        end
      else
        Datum.new(attrs)
      end
    end.compact
  end

  class << self
    def from_template(template)
      FieldSet.new(:attributes => template.shared_attributes.except(:data)).tap do |field_set|
        field_set.data = template.content_template.datum_templates.collect do |t|
          t.datum_class.constantize.from_template(t)
        end
      end
    end
  end
end