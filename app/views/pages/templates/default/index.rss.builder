xml.instruct! :xml, :version => "1.0" 
xml.rss(:version => "2.0") {
  xml.channel{
    xml.title(@field_set.node.name)
    xml.link(root_url)
    xml.language('sv-SV')
    @pages.each do |page|
      xml.item do
        xml.title(page.title)
        xml.pubDate(page.published_on.strftime("%a, %d %b %Y %H:%M:%S %z"))
        if page.index_node
          xml.link("#{root_url}#{page.index_node.url}/#{page.to_param}")
        elsif page.node
          xml.link("#{root_url}#{page.node.url}")
        end
      end
    end
  }
}
