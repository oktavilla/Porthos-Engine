# Sequences
Factory.sequence :url do |i|
  "/where/am/#{i}"
end

Factory.sequence :email do |i|
  "person#{i}@mash-app.com"
end

Factory.define :node do |f|
  f.url { Factory.next(:url) }
  f.controller "pages"
  f.action "index"
end

# Factory.define :page_node do |f|
#   f.url { Factory.next(:url) }
#   f.controller "pages"
#   f.action "index"
# end