module DataHelper
  def link_path(link)
    if link['url'].present?
      link.url
    elsif link.resource
      link.resource['url'] ? link.resource.url : page_path(link.resource)
    end
  end
end