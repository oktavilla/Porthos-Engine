module LinkListsHelper
  def navigation(link_list, options = {})
    seperator = options.delete(:seperator) || ' '
    content_tag 'nav', navigation_links(link_list).join(seperator).html_safe, { :class => link_list.handle }.merge(options)
  end

  def navigation_links(link_list)
    escaped_path = CGI.unescape(request.fullpath).mb_chars
    link_list.links.map do |link|
      if !!escaped_path.starts_with?(CGI.unescape(link.url).mb_chars)
        link_to(link.title, link.url, :class => 'current')
      else
        link_to(link.title, link.url)
      end
    end
  end
end