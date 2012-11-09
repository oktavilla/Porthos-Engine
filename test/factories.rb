require 'factory_girl'
# Sequences

FactoryGirl.define do
  sequence :title do |i|
    "A random title #{i}"
  end

  sequence :tag_name do |i|
    "keyword#{i}"
  end

  sequence :handle do |i|
    "handle_#{i}"
  end

  sequence :url do |i|
    "where/am/#{i}"
  end

  sequence :email do |i|
    "person#{i}@example.com"
  end

  sequence :username do |i|
    "person#{i}"
  end
end

FactoryGirl.define do
  factory :tag do |f|
    name { FactoryGirl.generate(:tag_name) }
  end

  factory :user do
    first_name 'Richie'
    last_name 'Hawtin'
    email { FactoryGirl.generate(:email) }
    username { FactoryGirl.generate(:username) }
    password 'password'
    password_confirmation 'password'
  end

  factory :node do
    url { FactoryGirl.generate(:url) }
    status 1
    controller "pages"
    action "index"
  end

  factory :root_node, :parent => :node do
    url nil
    name 'Start'
  end

  factory :link_list do
    title { FactoryGirl.generate(:title) }
    handle { FactoryGirl.generate(:handle) }
  end

  factory :link do
    title { FactoryGirl.generate(:title) }
    url { FactoryGirl.generate(:url) }
  end

  factory :node_link do
    title { FactoryGirl.generate(:title) }
    association :node, { factory: :node }
  end

  factory :content_template do
    label { FactoryGirl.generate(:title) }
    datum_templates {
      [
        FactoryGirl.build(:string_field_template),
        FactoryGirl.build(:text_field_template),
        FactoryGirl.build(:rich_text_field_template),
        FactoryGirl.build(:boolean_field_template),
        FactoryGirl.build(:date_field_template)
      ]
    }
  end

  factory :datum_template do
    label { FactoryGirl.generate(:title) }
    handle { FactoryGirl.generate(:title) }
    required false
  end

  factory :field_template, :class => FieldTemplate, :parent => :datum_template do
  end

  factory :string_field_template, :class => StringFieldTemplate, :parent => :field_template do
    input_type 'string'
  end

  factory :text_field_template, :parent => :string_field_template do
    multiline true
  end

  factory :rich_text_field_template, :parent => :text_field_template do
    allow_rich_text true
  end

  factory :boolean_field_template, :parent => :field_template do
    input_type 'boolean'
  end

  factory :date_field_template, :parent => :field_template do
    input_type 'date'
  end

  factory :datum_collection_template, :class => DatumCollectionTemplate, :parent => :datum_template do
  end

  factory :field_set_template do
    label { FactoryGirl.generate(:title) }
    handle { FactoryGirl.generate(:handle) }
    content_template { FactoryGirl.build(:content_template) }
  end

  factory :datum do
    label { FactoryGirl.generate(:title) }
    handle { FactoryGirl.generate(:handle) }
  end

  factory :field, :class => Field, :parent => :datum do
  end

  factory :string_field, :class => StringField, :parent => :field do
    input_type 'string'
  end

  factory :text_field, :parent => :string_field do
    multiline true
  end

  factory :rich_text_field, :parent => :text_field do
    allow_rich_text true
  end

  factory :boolean_field, :parent => :field do
    input_type 'boolean'
  end

  factory :date_field, :parent => :field do
    input_type 'date'
  end

  factory :field_set do
    label { FactoryGirl.generate(:title) }
    handle { FactoryGirl.generate(:title) }
    data {
      [
        FactoryGirl.build(:string_field),
        Field.from_template(FactoryGirl.build(:text_field_template)),
        Field.from_template(FactoryGirl.build(:rich_text_field_template)),
        FactoryGirl.build(:boolean_field),
        FactoryGirl.build(:date_field)
      ]
    }
  end

  factory :datum_collection, :class => DatumCollection, :parent => :datum do
  end

  factory :page_template do
    label { FactoryGirl.generate(:title) }
    handle { FactoryGirl.generate(:handle) }
    datum_templates {
      [
        FactoryGirl.build(:string_field_template, :label => 'Tagline'),
        FactoryGirl.build(:string_field_template),
        FactoryGirl.build(:field_set_template),
        FactoryGirl.build(:datum_collection_template)
      ]
    }
  end

  factory :hero_page_template, :parent => :page_template, :class => PageTemplate do
    page_label "Name"
    datum_templates {
      [
        FactoryGirl.build(:string_field_template, :label => 'Tagline', :handle => 'tagline', :required => true),
        FactoryGirl.build(:text_field_template, :label => 'Description', :handle => 'description', :required => true),
        FactoryGirl.build(:rich_text_field_template, :label => 'Biography', :handle => 'biography'),
        FactoryGirl.build(:boolean_field_template, :label => 'Has superpowers', :handle => 'superpowers'),
        FactoryGirl.build(:date_field_template, :label => 'Became publicly known at', :handle => 'debuted_at'),
        FactoryGirl.build(:datum_collection_template, :label => 'Main content', :handle => 'main_content')
      ]
    }
  end

  factory :item do
    title { FactoryGirl.generate(:title) }
  end

  factory :section, :parent => :item, :class => Section do
  end

  factory :page, :parent => :item, :class => Page do
    published_on { 1.week.ago }
  end

  factory :asset do
    association :created_by, :factory => :user
  end

  factory :image_asset, :parent => :asset, :class => ImageAsset do
  end

  # Factories for url resolver
  factory :post do
  end

  factory :author do
    handle { FactoryGirl.generate(:handle) }
  end

  factory :display_option do
    name "Half size"
    css_class "half"
    format "c100x50"
    group_handle "image"
  end
end
