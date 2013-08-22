module UrlHelper

  def node_url node
    node.root? ? base_url : "#{base_url}/#{node.slug}"
  end

  def base_url
    "#{request.protocol}#{request.host}"
  end

end
