module LinkListsHelper
  def navigation(link_list, options = {})
    seperator = options.delete(:seperator) || ' '
    content_tag 'nav', navigation_links(link_list).join(seperator).html_safe, { :class => link_list.handle }.merge(options)
  end

  def navigation_links(link_list)
    link_list.links.map do |link|
      if !!request.path.match(Regexp.new("^#{link.url}"))
        link_to(link.title, link.url, :class => 'current')
      else
        link_to(link.title, link.url)
      end
    end
  end
end