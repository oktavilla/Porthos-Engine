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
      content_template = template.is_a?(FieldSetTemplate) ? template.content_template : template
      content_template.to_datum.tap do |field_set|
        unless template == content_template
          field_set.attributes = field_set.attributes.stringify_keys.merge!(template.shared_attributes.stringify_keys)
        end
      end
    end
  end
end