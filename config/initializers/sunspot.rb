if Rails.application.config.use_fulltext_search

  Sunspot.setup(Page) do
    integer :field_set_id
    text :title, :boost => 2.0
    text :tag_names
    time :published_on
    boolean :is_restricted, :using => :in_restricted_context?
    text :body do
       contents_as_text
    end
    text :custom_attributes_values do
      custom_attributes.map { |ca| ca.value }.join(' ')
    end
    dynamic_string :custom_attributes do
      {}.tap do |hash|
        custom_associations.each do |custom_association|
          hash[custom_association.handle.to_sym] = "#{custom_association.target_type}-#{custom_association.target_id}"
        end
        custom_attributes.all.each do |custom_attribute|
          hash[custom_attribute.handle.to_sym] = !custom_attribute.value.acts_like?(:string) ? custom_attribute.value : ActionController::Base.helpers.strip_tags(custom_attribute.value)
        end
      end
    end
  end

  Sunspot.setup(Asset) do
    text :title, :boost => 2.0
    text :type, :name, :author, :description, :tag_names
    boolean :is_hidden, :using => :hidden?
  end

  Sunspot.setup(User) do
    text :first_name, :last_name, :email
  end

end
