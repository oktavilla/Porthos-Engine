class AssetUsages
  include Enumerable

  attr_reader :asset

  def initialize asset
    @asset = asset
  end

  def each &block
    using_objects.each &block
  end

  def add object, context = nil
    usage = new_usage object, context

    unless asset_usages.include?(usage)
      asset_usages << usage
      save_asset
    end
  end

  def remove object, context = nil
    usage = new_usage object, context
    asset_usages.reject! { |u| u == usage }
    save_asset
  end

  private

  def asset_usages
    asset._usages
  end

  def save_asset
    asset.save
  end

  def using_objects
    uniq_usages.collect do |usage|
      usage["usage_type"].constantize.find usage["usage_id"]
    end
  end

  def uniq_usages
    asset_usages.uniq {|usage| [usage["usage_id"], usage["usage_type"]] }
  end

  def new_usage object, context
    {
      "container_id" => context.to_s,
      "usage_type" => object.class.model_name,
      "usage_id" => object.id.to_s
    }
  end
end
