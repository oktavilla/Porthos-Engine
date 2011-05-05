class Textfield < Content
  key :title, String
  key :filter, String
  key :body, String

  validates_presence_of :body

  @@filters = %w(wymeditor html textile)
  @@default_filter = 'wymeditor'
  cattr_accessor :filters
  cattr_accessor :default_filter

  def filter
    @filter ||= self[:filter] || default_filter
  end
end