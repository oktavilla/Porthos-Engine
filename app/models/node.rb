class Node < ActiveRecord::Base
  belongs_to :resource,
             :polymorphic => true

  validates :url,
            :presence => true,
            :uniqueness => true
  validates :controller, :presence => true
  validates :action, :presence => true
end