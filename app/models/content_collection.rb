class ContentCollection < Content
  has_many :contents, :foreign_key => 'parent_id', :dependent => :destroy
end
