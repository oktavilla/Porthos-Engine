class ItemUpdater
  attr_reader :item, :item_attributes, :node_attributes

  def initialize item, attributes
    @item = item
    @node_attributes = attributes.delete(:node)
    @item_attributes = attributes
  end

  def update
    update_node
    update_item
  end

  private

  def update_item
    item.update_attributes(item_attributes)
  end

  def update_node
    if node && node_attributes
      node_update = node.update_attributes(node_attributes)
    end
  end

  def node
    if item.class == Section
      item.page_template_node
    else
      item.node
    end
  end

end
