class UserRole < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :role
  
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