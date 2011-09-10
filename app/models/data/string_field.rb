class StringField < Field
  key :multiline, Boolean, :default => lambda { false }
  key :allow_rich_text, Boolean, :default => lambda { false }

  before_validation do
    self.value.strip! if value.present?
  end

  def to_s
    value
  end

end