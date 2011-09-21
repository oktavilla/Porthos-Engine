class PagesSweeper < ActionController::Caching::Sweeper
  observe Page, Node, Content, CustomAttribute, CustomAssociation, BooleanAttribute,
    DateTimeAttribute, StringAttribute, TextAttribute, AssetUsage

  def after_create(item)
    clear_cache
  end

  def after_update(item)
    clear_cache
  end

  def after_destroy(item)
    clear_cache
  end

  private
  def clear_cache
    Rails.cache.clear
  end

end
