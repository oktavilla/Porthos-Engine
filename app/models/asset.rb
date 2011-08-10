class Asset
  include MongoMapper::Document
  include Tanker

  taggable

  key :name, String
  key :extension, String
  key :mime_type, String
  key :filetype, String
  key :size, Integer
  key :title, String
  key :author, String
  key :description, String
  key :hidden, Boolean, :default => lambda { false }
  key :created_by_id, ObjectId
  timestamps!

  tankit Porthos.config.tanking.index_name, :as => 'Asset' do
    indexes :name
    indexes :title
    indexes :description
    indexes :author
    indexes :tag_names
    indexes :hidden
  end

  belongs_to :created_by,
             :class_name => 'User'

  scope :is_hidden,  lambda { |hidden|
    where(:hidden => hidden)
  }

  scope :created_by, lambda { |user_id|
    where(:created_by_id => user_id)
  }

  scope :by_type, lambda { |type|
    where(:_type => type)
  }

  scope :by_filetype, lambda { |filetype|
    where(:filetype => filetype)
  }

  scope :order_by, lambda { |order|
    sort(order)
  }

  attr_accessor :file
  validates_presence_of :file, :if => :new_record?

  before_validation :process, :if => :new_record?
  after_destroy :cleanup

  after_save proc { |asset| Rails.env.production? ? asset.delay.update_tank_indexes : asset.update_tank_indexes }
  after_destroy proc { |asset| Rails.env.production? ? asset.delay.delete_tank_indexes : asset.delete_tank_indexes }

  @@filetypes = {
    :image => %w(jpg jpeg png gif tiff tif),
    :video => %w(flv mov qt mpg avi mp4),
    :sound => %w(mp3 wav aiff aif),
    :document => []
  }
  def self.filetypes; @@filetypes end
  def self.default_filetype
    @@filetypes.keys.detect do |key|
      @@filetypes[key].empty?
    end.to_s
  end

  def full_name
    @full_name ||= "#{name}.#{extension}"
  end

  def remote_url
    @remote_url ||= Porthos.s3_storage.details(full_name).url
  end

  class << self
    def uploaders
      User.find(self.fields(:created_by_id).distinct(:created_by_id))
    end

    def from_upload(attrs)
      extension = File.extname(attrs[:file].original_filename.downcase).gsub(/\./,'')
      if @@filetypes[:image].include?(extension)
        klass = ImageAsset
      else
        klass = Asset
      end
      klass.new(attrs)
    end

    def filetype_for_extension(_extension)
      Asset.default_filetype.tap do |_filetype|
        @@filetypes.each { |key, extensions| _filetype.replace(key.to_s) and break if extensions.include?(_extension) }
      end
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
      self.name    = original_filename.parameterize.to_s unless self.name.present?
      self.title   = original_filename unless self.title.present?
    end
    self.filetype = Asset.filetype_for_extension(extension)
  end

  def ensure_unique_name
    while !Asset.where(:name => self.name).count.zero? do
      self.name = "#{self.name}_#{SecureRandom.hex(8)}"
    end
  end

  def store
    unless Porthos.s3_storage.store(file, full_name)
      errors[:file] << t(:unable_to_store)
    end
    File.unlink(file.path) if file.respond_to?(:path)
  end

  # after destroy
  def cleanup
    Porthos.s3_storage.destroy(full_name)
  end
end