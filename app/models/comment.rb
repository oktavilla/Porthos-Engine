class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  validates_presence_of :name, :body  
  
  # acts_as_defensio_comment :fields => { :content => :body, :author => :name, :author_email => :email, :author_url => :url, :article => :commentable }
end
