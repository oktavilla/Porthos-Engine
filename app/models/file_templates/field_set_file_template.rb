class FieldSetFileTemplate < FileTemplate
  class << self
    def root_path
      File.join('field_set_templates')
    end
  end
end