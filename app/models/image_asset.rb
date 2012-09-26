class ImageAsset < Asset
  key :width, Integer
  key :height, Integer
  key :resizor_id, Integer
  key :versions, Hash, :default => lambda { Hash.new }

  tankit Porthos.config.tanking.index_name, :as => 'Asset' do
    indexes :name
    indexes :title
    indexes :description
    indexes :author
    indexes :tag_names
    indexes :hidden
    indexes :reference_number
  end

  validates_presence_of :resizor_id,
                        :on => :create,
                        :message => I18n.t(:unable_to_store)

  def remote_url(options = {})
    resizor_asset.url({:size => 'original', :format => extension}.merge(options))
  end
  alias :url :remote_url

  def versions=(new_version)
    super(versions.is_a?(Hash) ? versions.merge(new_version) : new_version)
  end

  def version_url(options = {})
    options = extract_cropping_options(options) if options[:size].start_with?('c')
    resizor_asset.url(options)
  end

  def landscape?
    width > height
  end

  def portrait?
    not landscape?
  end

  def height_for_width(new_width)
    unless new_width >= self.width
      (height.to_f * (new_width.to_f / self.width.to_f)).ceil
    else
      height
    end
  end

  def width_for_height(new_height)
    unless new_height >= self.height
      (width.to_f * (new_height.to_f / self.height.to_f)).ceil
    else
      width
    end
  end

protected

  def store
    resizor_asset.path = File.join(Dir.tmpdir, file.original_filename).tap do |_path|
      file.respond_to?(:path) ? FileUtils.move(file.path, _path) : File.open(_path, 'wb') { |f| f.write(file.read) }
    end
    if resizor_asset.save_to_resizor
      self.resizor_id = resizor_asset.id
      self.width = resizor_asset.width
      self.height = resizor_asset.height
      File.unlink(resizor_asset.path)
    end
  end

  def cleanup
    resizor_asset.destroy
  end

  def resizor_asset
    @resizor_asset ||= Resizor::ResizorAsset.new(:id => self.resizor_id)
  end

private

  def extract_cropping_options(options)
    options.tap do |opts|
      size = opts[:size]
      unless versions.has_key?(size)
        add_version size
      else
        version = versions[size]
        if version.keys.any?
          opts[:cutout] = "#{version[:cutout_width]}x#{version[:cutout_height]}-#{version[:cutout_x]}x#{version[:cutout_y]}"
        end
      end
    end
  end

  def add_version(size)
    self.versions[size] = {}
    set("versions.#{size}" => self.versions[size])
  end

end
