class ContentBlock < Datum
  many :data

  before_save :sort_data

protected

  def sort_data
    self.data.sort_by!(&:position)
  end

end