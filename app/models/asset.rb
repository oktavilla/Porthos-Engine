class Asset < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User'
  has_many   :usages, :class_name => 'AssetUsage',
                      :dependent => :destroy
  has_many :custom_associations,
           :as => :target,
           :dependent => :destroy

  scope :is_hidden,  lambda { |hidden| {:conditions => ['hidden = ?', hidden ]}}
  scope :created_by, lambda { |user_id| { :conditions => ["created_by_id = ?", user_id] }}
  scope :by_type,    lambda { |type| { :conditions => ["type = ?", type] }}
  scope :order_by,   lambda { |order| { :order => order }}

  attr_accessor :file
  validates_presence_of :file, :on => :create

  before_validation :process, :on => :create
  after_destroy :cleanup
  after_save :commit_to_sunspot

  acts_as_taggable

  IMAGE_FORMATS = [:jpg, :jpeg, :png, :gif]
  VIDEO_FORMATS = [:flv, :mov, :qt, :mpg, :avi, :mp4]
  SOUND_FORMATS = [:mp3, :wav, :aiff, :aif]

  def to_param
    name
  end

  def full_name
    @full_name ||= "#{name}.#{extension}"
  end

  def remote_url
    @remote_url ||= Porthos.s3_storage.details(full_name).url
  end

  def attributes_for_js
    self.attributes
  end

  class << self
    def from_upload(attrs)
      extension = File.extname(attrs[:file].original_filename.downcase).gsub(/\./,'')
      if IMAGE_FORMATS.include?(extension.to_sym)
        klass = ImageAsset
      else
        klass = Asset
      end
      klass.new(attrs)
    end

  end

protected

  # before validation on create
  def process
    extract_attributes_from_file
    ensure_unique_name
    store
  end

  def extract_attributes_from_file
    self.size      = file.size
    self.mime_type = MIME::Types.type_for(file.original_filename).first.to_s
    self.extension = File.extname(file.original_filename).gsub(/\./,'').gsub(/\?.*/,'').downcase
    file.original_filename.gsub(".#{read_attribute(:extension)}",'').tap do |original_filename|
      self.name    = original_filename.parameterize.to_s
      self.title   = original_filename
    end
  end

  def ensure_unique_name
    while !Asset.count(:conditions => ['name = ?', self.name]).zero? do
      self.name = "#{self.name}_#{ActiveSupport::SecureRandom.hex(8)}"
    end
  end

  def store
    unless Porthos.s3_storage.store(file, full_name)
      errors[:file] << t(:unable_to_store, :scope => [:activerecord, :errors, :models, :asset, :file])
    end
    File.unlink(file.path) if file.respond_to?(:path)
  end

  # after destroy
  def cleanup
    Porthos.s3_storage.destroy(full_name)
  end

  # after save
  def commit_to_sunspot
    Delayed::Job.enqueue SunspotIndexJob.new('Asset', self.id)
  end
end
