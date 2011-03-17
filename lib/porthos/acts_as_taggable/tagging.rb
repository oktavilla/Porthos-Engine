class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  named_scope :with_taggable_type, lambda { |type| {
   :conditions => ["taggable_type = ? ", type] 
  }}
  
end