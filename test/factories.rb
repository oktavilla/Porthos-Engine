# Sequences

Factory.sequence :title do |i|
  "A random title #{i}"
end

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

Factory.define :field_set do |f|
  f.title "Default"
  f.page_label "Default page"
  f.handle 'default'
end

Factory.define :field do |f|
  f.association :field_set
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:title) }
end

Factory.define :page do |f|
  f.title { Factory.next(:title) }
  f.association :field_set
end

Factory.define :custom_attribute do |f|
  f.association :context, :factory => :page
  f.association :field
end

# Factories for url resolver
Factory.define :test_post do |f|
end

Factory.define :test_blog_node, :parent => :node do |f|
  f.controller 'test_posts'
  f.action 'index'
end

Factory.define :test_blog_post_node, :parent => :test_blog_node do |f|
  f.action 'show'
  f.resource { Factory(:test_post) }
end