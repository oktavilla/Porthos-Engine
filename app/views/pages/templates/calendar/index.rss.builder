xml.instruct! :xml, :version => "1.0"
xml.rss(:version => "2.0") {
  xml.channel{
    xml.title(@page_renderer.node.name)
    xml.link(root_url)
    xml.language('sv-SV')
    @page_renderer.pages.each do |page|
      xml.item do
        xml.title(page.title)
        xml.pubDate(page.published_on.strftime("%a, %d %b %Y %H:%M:%S %z"))
        if page.index_node
          xml.link("#{root_url}#{page.index_node.url}/#{page.to_param}")
        elsif page.node
          xml.link("#{root_url}/#{page.index_node.url}/#{page.published_on.strftime("%Y/%m/%d")}/#{page.to_param}")
        end
      end
    end
  }
}
