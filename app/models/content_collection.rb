class ContentCollection < Content
  has_many :contents, :order => 'position', :foreign_key => 'parent_id', :dependent => :destroy
end
