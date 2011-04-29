# Sequences

Factory.sequence :title do |i|
  "A random title #{i}"
end

Factory.sequence :tag_name do |i|
  "keyword#{i}"
end

Factory.sequence :handle do |i|
  "handle_#{i}"
end

Factory.sequence :url do |i|
  "where/am/#{i}"
end

Factory.sequence :email do |i|
  "person#{i}@example.com"
end

Factory.sequence :username do |i|
  "person#{i}"
end

Factory.define :tag do |f|
  f.name { Factory.next(:tag_name) }
end

Factory.define :user do |f|
  f.first_name 'Richie'
  f.last_name 'Hawtin'
  f.email { Factory.next(:email) }
  f.username { Factory.next(:username) }
  f.password 'password'
  f.password_confirmation 'password'
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
  f.fields {
    [
      Factory.build(:string_field),
      Factory.build(:text_field),
      Factory.build(:rich_text_field)
    ]
  }
end

Factory.define :field do |f|
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:title) }
end

Factory.define :string_field, :class => StringField, :parent => :field do |f|
end

Factory.define :text_field, :parent => :string_field do |f|
  f.multiline true
end

Factory.define :rich_text_field, :parent => :text_field do |f|
  f.allow_rich_text true
end

Factory.define :boolean_field, :class => BooleanField, :parent => :field do |f|
end

Factory.define :date_time_field, :class => DateTimeField, :parent => :field do |f|
end

Factory.define :page do |f|
  f.field_set { Factory(:field_set) }
  f.title { Factory.next(:title) }
end

Factory.define :custom_attribute do |f|
  f.association :context, :factory => :page
  f.association :field
end

Factory.define :string_attribute, :class => StringAttribute, :parent => :custom_attribute do |f|
end

Factory.define :date_time_attribute, :class => DateTimeAttribute, :parent => :custom_attribute do |f|
end

Factory.define :custom_association do |f|
  f.association :context, :factory => :page
  f.association :target, :factory => :page
  f.association :field
  f.handle { Factory.next(:handle) }
  f.relationship 'one_to_one'
end

Factory.define :asset do |f|
  f.association :created_by, :factory => :user
end

Factory.define :image_asset, :parent => :asset, :class => ImageAsset do |f|
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
