class Redirect
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  key :path, String
  key :target, String

  timestamps!

  validates_presence_of :path, :target
  validates_length_of :path, minimum: 2
  validates_uniqueness_of :path

  validates_format_of :path,
    with: /^\/(.*?)/,
    message: I18n.t(:bad_redirect_format, scope: [:app, :validators])

  before_save :remove_trailing_slash

protected
  def remove_trailing_slash
    path.chop! if path.end_with?('/')
  end
end
