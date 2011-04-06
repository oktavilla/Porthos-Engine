class ImageAsset < Asset
  validates_presence_of :resizor_id,
                        :on => :create,
                        :message => I18n.t(:unable_to_store, :scope => [:activerecord, :models, :asset, :file])

  def remote_url
    resizor_asset.url(:size => 'original', :format => extension)
  end

  def version_url(options = {})
    resizor_asset.url(options)
  end

  def landscape?
    width > height
  end

  def portrait?
    not landscape?
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
end