class Redirect < ActiveRecord::Base
  validates_presence_of :path, :target
  validates_length_of :path, :minimum => 2
  validates_uniqueness_of :path 
  
  validates_format_of :path, :with => /^\/(.*?)/, :message => 'måste börja med ett /-tecken'
  
  before_save :remove_trailing_slash
  
protected
  def remove_trailing_slash
    path.chop! if path[-1,1] == '/'
  end
end