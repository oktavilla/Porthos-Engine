class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable,
             :polymorphic => true,
             :touch => true

  scope :with_taggable_type, lambda { |type|
   where("taggable_type = ? ", type)
  }

  scope :with_namespace, lambda { |namespace|
    where("taggings.namespace = ?", namespace)
  }

  scope :without_namespace, where('taggings.namespace IS NULL')
end