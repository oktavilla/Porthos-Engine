require 'digest/sha1'
class User < ActiveRecord::Base
  # class accessor to be set and unset in the application controller
  # used to be able to access the current logged in user (controller variable) in models
  cattr_accessor :current
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  # Virtual attribute for uploaded avatar file
  attr_accessor :file

  has_many :user_roles
  has_many :roles, :through => :user_roles

  has_many :created_pages, :foreign_key => 'created_by_id', :class_name => 'Page', :order => 'created_at DESC'
  has_many :updated_pages, :foreign_key => 'updated_by_id', :class_name => 'Page', :order => 'updated_at DESC'

  belongs_to :avatar, :foreign_key => 'avatar_id', :class_name => 'ImageAsset'

  validates_presence_of     :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40, :allow_blank => true
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :login, :case_sensitive => false, :allow_blank => true

  before_save :encrypt_password, :save_avatar

  scope :recent_contributers,
        select('DISTINCT users.*').
        from('pages').
        joins('LEFT JOIN users ON users.id = pages.updated_by_id').
        where('pages.updated_by_id IS NOT NULL AND users.id IS NOT NULL').
        order('pages.updated_by_id DESC').
        group('pages.updated_by_id')

  scope :recent_uploaders,
        select('DISTINCT users.*').
        from('assets').
        joins('LEFT JOIN users ON users.id = assets.created_by_id').
        conditions('assets.created_by_id IS NOT NULL AND users.id IS NOT NULL').
        group('assets.created_by_id')

  acts_as_filterable

  scope :filter_role , lambda { |role_name|
    scoped = includes('roles')
    role_name.blank? ? scoped : scoped.where("roles.name = ?", role_name)
  }

  searchable :auto_index => false do
    text :first_name, :last_name, :email
  end

  after_save :commit_to_sunspot

  def validate
    if file and file.size.nonzero?
      unless Asset::IMAGE_FORMATS.include?(File.extname(file.original_filename).gsub(/\./,'').downcase.to_sym)
        errors[:file] = t(:unkown_format, :scope => [:app, :images_asset])
      end
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{first_name} #{!last_name.blank? ? last_name[0...1]+'.' : ''}"
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find(:first, :conditions => ["login = ? or email = ?", login, login]) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def generate_new_password!
    self.password = encrypt(Time.now)[0..6]
    save(false)
  end

  # Asks the resource if we have the rights to create it
  def can_create?(resource)
    resource.can_be_created_by?(self)
  end

  # Asks the resource if we have the rights to edit it
  def can_edit?(resource)
    resource.can_be_edited_by?(self)
  end

  # Asks the resource if we have the rights to delete it
  def can_destroy?(resource)
    resource.can_be_destroyed_by?(self)
  end

  class << self
    def can_be_edited_by?(user)
      user.admin? || user == self
    end

    # Users can not delete them selfs
    def can_be_destroyed_by?(user)
      (user.admin? and user != self) || user == self
    end

    # hash with methods allowed to be called form the restriction model
    # key's should be used for translations and values for the method names
    def allowed_restrictions
      {} # override per installation
    end

  end

  def admin?
    has_role?('Admin')
  end

  def has_role?(role)
    self.roles.count(:conditions => ['name = ?', role]) > 0
  end

  def add_role(role)
    return if self.has_role?(role)
    self.roles << Role.find_by_name(role)
  end

protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def save_avatar
    if file and file.size.nonzero?
      self.avatar.destroy if self.avatar
      self.avatar = ImageAsset.create(:title => name, :file => file, :private => true)
    end
  end

  def commit_to_sunspot
    Delayed::Job.enqueue SunspotIndexJob.new('User', self.id)
  end
end
