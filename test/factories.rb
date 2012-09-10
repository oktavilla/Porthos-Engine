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
    f.name { FactoryGirl.generate(:tag_name) }
  end

  factory :user do |f|
    f.first_name 'Richie'
    f.last_name 'Hawtin'
    f.email { FactoryGirl.generate(:email) }
    f.username { FactoryGirl.generate(:username) }
    f.password 'password'
    f.password_confirmation 'password'
  end

  factory :node do |f|
    f.url { FactoryGirl.generate(:url) }
    f.status 1
    f.controller "pages"
    f.action "index"
  end

  factory :root_node, :parent => :node do |f|
    f.url nil
    f.name 'Start'
  end

  factory :link_list do |f|
    f.title { FactoryGirl.generate(:title) }
    f.handle { FactoryGirl.generate(:handle) }
  end

  factory :link do |f|
    f.title { FactoryGirl.generate(:title) }
    f.url { FactoryGirl.generate(:url) }
  end

  factory :node_link do |f|
    f.title { FactoryGirl.generate(:title) }
    f.association :node, { factory: :node }
  end

  factory :content_template do |f|
    f.label { FactoryGirl.generate(:title) }
    f.datum_templates {
      [
        FactoryGirl.build(:string_field_template),
        FactoryGirl.build(:text_field_template),
        FactoryGirl.build(:rich_text_field_template),
        FactoryGirl.build(:boolean_field_template),
        FactoryGirl.build(:date_field_template)
      ]
    }
  end

  factory :datum_template do |f|
    f.label { FactoryGirl.generate(:title) }
    f.handle { FactoryGirl.generate(:title) }
    f.required false
  end

  factory :field_template, :class => FieldTemplate, :parent => :datum_template do |f|
  end

  factory :string_field_template, :class => StringFieldTemplate, :parent => :field_template do |f|
    f.input_type 'string'
  end

  factory :text_field_template, :parent => :string_field_template do |f|
    f.multiline true
  end

  factory :rich_text_field_template, :parent => :text_field_template do |f|
    f.allow_rich_text true
  end

  factory :boolean_field_template, :parent => :field_template do |f|
    f.input_type 'boolean'
  end

  factory :date_field_template, :parent => :field_template do |f|
    f.input_type 'date'
  end

  factory :datum_collection_template, :class => DatumCollectionTemplate, :parent => :datum_template do |f|
  end

  factory :field_set_template do |f|
    f.label { FactoryGirl.generate(:title) }
    f.handle { FactoryGirl.generate(:handle) }
    f.content_template { FactoryGirl.build(:content_template) }
  end

  factory :datum do |f|
    f.label { FactoryGirl.generate(:title) }
    f.handle { FactoryGirl.generate(:handle) }
  end

  factory :field, :class => Field, :parent => :datum do |f|
  end

  factory :string_field, :class => StringField, :parent => :field do |f|
    f.input_type 'string'
  end

  factory :text_field, :parent => :string_field do |f|
    f.multiline true
  end

  factory :rich_text_field, :parent => :text_field do |f|
    f.allow_rich_text true
  end

  factory :boolean_field, :parent => :field do |f|
    f.input_type 'boolean'
  end

  factory :date_field, :parent => :field do |f|
    f.input_type 'date'
  end

  factory :field_set do |f|
    f.label { FactoryGirl.generate(:title) }
    f.handle { FactoryGirl.generate(:title) }
    f.data {
      [
        FactoryGirl.build(:string_field),
        Field.from_template(FactoryGirl.build(:text_field_template)),
        Field.from_template(FactoryGirl.build(:rich_text_field_template)),
        FactoryGirl.build(:boolean_field),
        FactoryGirl.build(:date_field)
      ]
    }
  end

  factory :datum_collection, :class => DatumCollection, :parent => :datum do |f|
  end

  factory :page_template do |f|
    f.label { FactoryGirl.generate(:title) }
    f.handle { FactoryGirl.generate(:handle) }
    f.datum_templates {
      [
        FactoryGirl.build(:string_field_template, :label => 'Tagline'),
        FactoryGirl.build(:string_field_template),
        FactoryGirl.build(:field_set_template),
        FactoryGirl.build(:datum_collection_template)
      ]
    }
  end

  factory :hero_page_template, :parent => :page_template, :class => PageTemplate do |f|
    f.page_label "Name"
    f.datum_templates {
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

  factory :item do |f|
    f.title { FactoryGirl.generate(:title) }
  end

  factory :section, :parent => :item, :class => Section do |f|
  end

  factory :page, :parent => :item, :class => Page do |f|
    f.published_on { 1.week.ago }
  end

  factory :asset do |f|
    f.association :created_by, :factory => :user
  end

  factory :image_asset, :parent => :asset, :class => ImageAsset do |f|
  end

  # Factories for url resolver
  factory :post do |f|
  end

  factory :author do |f|
    f.handle { FactoryGirl.generate(:handle) }
  end
end
