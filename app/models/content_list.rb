class ContentList < ActiveRecord::Base
  has_many :contents,
           :as    => :context,
           :order => 'contents.position',
           :conditions => ['parent_id IS NULL']
  validates_presence_of :handle
  validates_uniqueness_of :handle
end
