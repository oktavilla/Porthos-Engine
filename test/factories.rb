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
  f.status 1
  f.controller "pages"
  f.action "index"
end

Factory.define :root_node, :parent => :node do |f|
  f.url nil
  f.name 'Start'
end

Factory.define :content_template do |f|
  f.label { Factory.next(:title) }
  f.datum_templates {
    [
      Factory.build(:string_field_template),
      Factory.build(:text_field_template),
      Factory.build(:rich_text_field_template),
      Factory.build(:boolean_field_template),
      Factory.build(:date_field_template)
    ]
  }
end

Factory.define :datum_template do |f|
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:title) }
  f.required false
end

Factory.define :field_template, :class => FieldTemplate, :parent => :datum_template do |f|
end

Factory.define :string_field_template, :class => StringFieldTemplate, :parent => :field_template do |f|
  f.input_type 'string'
end

Factory.define :text_field_template, :parent => :string_field_template do |f|
  f.multiline true
end

Factory.define :rich_text_field_template, :parent => :text_field_template do |f|
  f.allow_rich_text true
end

Factory.define :boolean_field_template, :parent => :field_template do |f|
  f.input_type 'boolean'
end

Factory.define :date_field_template, :parent => :field_template do |f|
  f.input_type 'date'
end

Factory.define :content_block_template, :class => ContentBlockTemplate, :parent => :datum_template do |f|
end

Factory.define :field_set_template do |f|
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:handle) }
  f.content_template { Factory.build(:content_template) }
end

Factory.define :datum do |f|
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:handle) }
end

Factory.define :field, :class => Field, :parent => :datum do |f|
end

Factory.define :string_field, :class => StringField, :parent => :field do |f|
  f.input_type 'string'
end

Factory.define :text_field, :parent => :string_field do |f|
  f.multiline true
end

Factory.define :rich_text_field, :parent => :text_field do |f|
  f.allow_rich_text true
end

Factory.define :boolean_field, :parent => :field do |f|
  f.input_type 'boolean'
end

Factory.define :date_field, :parent => :field do |f|
  f.input_type 'date'
end

Factory.define :field_set do |f|
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:title) }
  f.data {
    [
      Factory.build(:string_field),
      Field.from_template(Factory.build(:text_field_template)),
      Field.from_template(Factory.build(:rich_text_field_template)),
      Factory.build(:boolean_field),
      Factory.build(:date_field)
    ]
  }
end

Factory.define :content_block, :class => ContentBlock, :parent => :datum do |f|
end

Factory.define :page_template do |f|
  f.label { Factory.next(:title) }
  f.handle { Factory.next(:handle) }
  f.datum_templates {
    [
      Factory.build(:string_field_template, :label => 'Tagline'),
      Factory.build(:string_field_template),
      Factory.build(:field_set_template),
      Factory.build(:content_block_template)
    ]
  }
end

Factory.define :hero_page_template, :class => PageTemplate do |f|
  f.label "Hero"
  f.page_label "Name"
  f.handle 'hero'
  f.datum_templates {
    [
      Factory.build(:string_field_template, :label => 'Tagline', :handle => 'tagline', :required => true),
      Factory.build(:text_field_template, :label => 'Description', :handle => 'description', :required => true),
      Factory.build(:rich_text_field_template, :label => 'Biography', :handle => 'biography'),
      Factory.build(:boolean_field_template, :label => 'Has superpowers', :handle => 'superpowers'),
      Factory.build(:date_field_template, :label => 'Became publicly known at', :handle => 'debuted_at'),
      Factory.build(:content_block_template, :label => 'Main content', :handle => 'main_content')
    ]
  }
end

Factory.define :page do |f|
  f.title { Factory.next(:title) }
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
Factory.define :post do |f|
end

Factory.define :author do |f|
end

Factory.define :test_blog_node, :parent => :node do |f|
  f.controller 'posts'
  f.action 'index'
  f.handle 'blog'
end

Factory.define :test_blog_post_node, :parent => :node do |f|
  f.controller 'posts'
  f.action 'show'
  f.resource { Factory(:post) }
end
