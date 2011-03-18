# == Schema Information
# Schema version: 76
#
# Table name: contents
#
#  id                              :integer(11)   not null, primary key
#  page_id                         :integer(11)   
#  column_position                 :integer(11)   
#  position                        :integer(11)   
#  resource_id                     :integer(11)   
#  resource_type                   :string(255)   
#  created_at                      :datetime      
#  updated_at                      :datetime      
#  parent_id                       :integer(11)   
#  type                            :string(255)   
#  accepting_content_resource_type :string(255)   
#

class ContentCollection < Content
  has_many :contents, :order => 'position', :foreign_key => 'parent_id', :dependent => :destroy
end
