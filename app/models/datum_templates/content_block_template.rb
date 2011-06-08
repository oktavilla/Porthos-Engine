class ContentBlockTemplate < DatumTemplate
  key :allow_texts, Boolean, :default => lambda { false }
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  key :allowed_page_template_ids, Array, :typecast => 'ObjectId', :default => lambda { [] }
  key :content_templates_ids, Array, :typecast => 'ObjectId', :default => lambda { [] }

  many :content_templates, :in => :content_templates_ids

  before_validation do
    self.allowed_asset_filetypes = allowed_asset_filetypes.compact.reject { |i| i.blank? }
    self.allowed_page_template_ids = allowed_page_template_ids.compact.reject { |i| i.blank? }
    self.content_templates_ids = content_templates_ids.compact.reject { |i| i.blank? }
  end

private

  # FIXME: This should not run after sorting
  def propagate_changes
    query_handle = if respond_to?(:handle_changed?)
      handle_changed? ? handle_was : handle
    else
      handle
    end

    Page.collection.update({
      'page_template_id' => self._root_document.id,
      'data.handle' => query_handle,
    }, {
      '$set' => {
        'data.$.label' => self.label,
        'data.$.handle' => query_handle,
        'data.$.required' => self.required,
        'data.$.allowed_asset_filetypes' => self.allowed_asset_filetypes,
        'data.$.allowed_page_template_ids' => self.allowed_page_template_ids,
        'data.$.content_templates_ids' => self.content_templates_ids,
        'data.$.allow_texts' => self.allow_texts
      }
    }, :multi => true, :safe => true)
  end

  def propagate_self
    Page.collection.update({
      'page_template_id' => self._root_document.id
    }, {
      '$addToSet' => {
        'data' => ContentBlock.from_template(self).to_mongo
      }
    }, :multi => true, :safe => true)
  end

end
