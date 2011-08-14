module DataHelper
  def link_path(link)
    if link.url.present?
      link.url
    elsif link.resource
      link.resource.kind_of?(Item) ? page_path(link.resource) : link.resource.url
    end
  end
end