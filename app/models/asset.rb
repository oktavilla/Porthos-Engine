class Asset
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

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
  key :reference_number, String
  key :hidden, Boolean, default: -> { false }
  key :created_by_id, ObjectId
  key :_usages, Array, default: -> { [] }
  timestamps!

  tankit Porthos.config.tanking.index_name, :as => 'Asset' do
    indexes :name
    indexes :title
    indexes :author
    indexes :description
    indexes :reference_number
    indexes :tag_names
    indexes :hidden
  end

  class_attribute :filetypes
  self.filetypes = {
    :image => %w(jpg jpeg png gif tiff tif),
    :video => %w(flv mov qt mpg avi mp4),
    :sound => %w(mp3 wav aiff aif),
    :pdf   => %w(pdf),
    :document => []
  }

  belongs_to :created_by, class_name: "User"

  scope :is_hidden, ->(hidden) { where(hidden: hidden) }

  scope :created_by, ->(user_id) { where(created_by_id: user_id) }

  scope :by_type, ->(type) { where(_type: type) }

  scope :by_filetype, ->(filetype) { where(filetype: filetype) }

  scope :by_extension, ->(extension) {
    if extension.is_a?(Array)
      where(:extension.in => extension)
    else
      where(extension: extension)
    end
  }

  scope :order_by, ->(order) { sort(order) }

  attr_accessor :file
  validates_presence_of :file, :if => :new_record?

  before_validation :process
  after_destroy :cleanup

  after_save proc { |asset| asset.delay.update_tank_indexes }
  after_destroy proc { |asset| asset.delete_tank_indexes }

  def self.default_filetype
    filetypes.keys.detect do |key|
      filetypes[key].empty?
    end.to_s
  end

  def full_name
    @full_name ||= "#{name}.#{extension}"
  end

  def remote_url
    @remote_url ||= Porthos.s3_storage.url(full_name)
  end

  def of_the_type(filetype)
    type = self.filetypes[filetype.to_sym]
    type && type.include?(self.extension)
  end

  def usages
    @usages ||= _usages.map do |u|
      u.except('container_id')
    end.uniq.collect { |u| u['usage_type'].constantize.find(u['usage_id']) }
  end

  def remove_usage(association)
    usage = usage_from_association(association)
    if _usages.include?(usage)
      _usages.reject! { |u| u == usage }
      save
    end
  end

  def add_usage(association)
    usage = usage_from_association(association)
    unless _usages.include?(usage)
      _usages << usage
      save
    end
  end

  class << self
    def uploaders
      User.find(self.fields(:created_by_id).distinct(:created_by_id))
    end

    def from_upload(attrs)
      extension = File.extname(attrs[:file].original_filename.downcase).gsub(/\./,'')
      if filetypes[:image].include?(extension)
        klass = ImageAsset
      else
        klass = Asset
      end
      klass.new(attrs)
    end

    def filetype_for_extension(_extension)
      Asset.default_filetype.tap do |_filetype|
        filetypes.each { |key, extensions| _filetype.replace(key.to_s) and break if extensions.include?(_extension) }
      end
    end
  end

  protected

  def process
    if file.present?
      extract_attributes_from_file
      ensure_unique_name

      cleanup unless new_record?

      store
    end
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

  def usage_from_association(association)
    {
      'container_id' => association.id,
      'usage_type' => association._root_document.class.model_name,
      'usage_id' => association._root_document.id.to_s
    }
  end

end
