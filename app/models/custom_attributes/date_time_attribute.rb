class DateTimeAttribute < CustomAttribute
  self.value_attribute = :date_time_value

  def value=(value)
    value = if value.is_a?(Hash)
      attrs = value.to_options
      DateTime.new(*[
        attrs[:year],
        attrs[:month],
        attrs[:day],
        attrs[:hour],
        attrs[:minute]
      ].collect { |part| part.to_i })
    else
      value
    end
    super value
  end

end