class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true

  scope :with_taggable_type, lambda { |type|
   where("taggable_type = ? ", type)
  }

end