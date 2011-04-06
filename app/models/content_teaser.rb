class ContentTeaser < ActiveRecord::Base
  include Porthos::ContentResource

  has_one :content, :as => :resource

  belongs_to :parent, :polymorphic => true
  belongs_to :product_category
  belongs_to :product

  has_many :asset_usages, :as => :parent, :dependent => :destroy
  has_many :images, :source => :asset, :through => :asset_usages, :conditions => "assets.type = 'ImageAsset'", :select => "assets.*, asset_usages.gravity" do
    def primary
      find(:first)
    end
  end

  # acts_as_list :scope => 'parent_id = \'#{parent_id}\' and parent_type = \'#{parent_type}\''

  validates_presence_of :title, :body

  attr_accessor :files

  @@filters = %w(wymeditor html textile)
  cattr_accessor :filters

  @@default_filter = 'wymeditor'
  cattr_accessor :default_filter

  def filter
    @filter ||= read_attribute(:filter) || default_filter
  end

  @@display_types = [
    { :key => 'small',  :image_size => 100 },
    { :key => 'medium', :image_size => 200 },
    { :key => 'big',    :image_size => 300 }
  ]
  cattr_accessor :display_types

  def image_size
    @image_size ||= display_types[display_type.to_i][:image_size]
  end

  def display_type_key
    @display_type_key ||= display_types[display_type.to_i][:key]
  end

  self.class_eval do

    display_types.each do |_type|
      define_method("#{_type[:key]}?".to_sym) do
        self.display_types[read_attribute(:display_type).to_i][:key] == _type[:key]
      end
    end

  end

  @@css_classes = ['light_magenta', 'light_cyan', 'light_green',
                   'magenta', 'cyan', 'green', 'red']
  cattr_accessor :css_classes

  IMAGE_DISPLAY_TYPES = { :only_first_image => 0, :slideshow => 1 }

  after_save :save_files

  def has_slideshow?
    images.size > 1 and images_display_type == IMAGE_DISPLAY_TYPES[:slideshow]
  end

protected
  # after save
  def save_files
    if files
      files.each do |file|
        begin
          if file and file.size.nonzero?
            AssetUsage.transaction do
              image = ImageAsset.create!(:title => title, :file => file)
              asset_usage = self.asset_usages.build
              asset_usage.asset = image
              asset_usage.save!
            end
          end
        rescue ActiveRecord::RecordInvalid
          next
        end
      end
    end
  end
end
