class User
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  attr_reader :password

  key :first_name, String
  key :last_name, String
  key :username, String
  key :password_digest, String
  key :remember_me_token, String
  key :email, String

  key :phone, String
  key :cell_phone, String

  timestamps!
  # class accessor to be set and unset in the application controller
  # used to be able to access the current logged in user (controller variable) in models
  cattr_accessor :current

  validates :first_name,
            :presence => true
  validates :last_name,
            :presence => true
  validates :password,
            :confirmation => true,
            :presence => true,
            :if => :new?
  validates :username,
            :presence => true,
            :uniqueness => { :case_sensitive => false }
  validates :email,
            :presence => true,
            :uniqueness => { :case_sensitive => false }

  def password=(unencrypted_password)
    @password = unencrypted_password
    self.password_digest = BCrypt::Password.create(unencrypted_password) unless unencrypted_password.blank?
  end

  def authenticate(unencrypted_password)
    if BCrypt::Password.new(password_digest) == unencrypted_password
      self
    else
      false
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{first_name} #{!last_name.blank? ? last_name[0...1]+'.' : ''}"
  end

  def generate_remember_me_token!
    "#{id.to_s}#{SecureRandom.hex(24)}".tap do |token|
      self.update_attribute(:remember_me_token, token)
    end
  end

  class << self
    def authenticate(username, password)
      user = where(:username => username).first
      if user
        user.authenticate(password)
      else
        false
      end
    end
  end
end
