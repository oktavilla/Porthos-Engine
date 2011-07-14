module LinkListsHelper
  def navigation(link_list, options = {})
    links = ''
    link_list.links.each do |link|
      if !!request.path.match(Regexp.new("^#{link.url}"))
        links << link_to(link.title, link.url, :class => 'current')
      else
        links << link_to(link.title, link.url)
      end
    end
    content_tag 'nav', links.html_safe, { :class => link_list.handle }.merge(options)
  end
end