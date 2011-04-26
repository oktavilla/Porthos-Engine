class User
  include MongoMapper::Document

  attr_reader :password

  key :first_name, String
  key :last_name, String
  key :username, String
  key :password_digest, String
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

  # scope :recent_contributers,
  #       select('users.*').
  #       joins('LEFT OUTER JOIN pages ON pages.updated_by_id = users.id').
  #       where('pages.updated_by_id IS NOT NULL')
  #
  # scope :recent_uploaders,
  #       select('DISTINCT users.id, users.*').
  #       joins('LEFT OUTER JOIN assets ON assets.created_by_id = users.id').
  #       where('assets.created_by_id IS NOT NULL')

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