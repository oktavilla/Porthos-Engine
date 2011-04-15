class BooleanAttribute < CustomAttribute
  self.value_attribute = :boolean_value

  key :boolean_attribute, Boolean
end
