class Role < ActiveRecord::Base
  
  has_many :user_roles
  has_many :users, :through => :user_roles
  
  class << self
    def can_be_created_by?(user)
      user.admin?
    end

    def can_be_edited_by?(user)
      user.admin?
    end

    def can_be_destroyed_by?(user)
      user.admin?
    end
  end
end