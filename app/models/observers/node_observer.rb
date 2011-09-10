class NodeObserver < Porthos::MongoMapper::Observer

  def after_update(node)
    LinkList.collection.update({ 'links.node_id' => node.id }, {
      '$set' => { 'links.$.node_url' => "/#{node.url}" }
    }, multi: true)
  end

end