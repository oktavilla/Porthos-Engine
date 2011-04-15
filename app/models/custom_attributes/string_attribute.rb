class StringAttribute < CustomAttribute
  self.value_attribute = :string_value

  key :string_value, String
end
