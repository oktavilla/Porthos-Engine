class ContentBlockTemplate < DatumTemplate
  key :allow_texts, Boolean, :default => lambda { false }
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  key :allowed_page_template_ids, Array, :typecast => 'ObjectId', :default => lambda { [] }
  key :content_templates_ids, Array, :typecast => 'ObjectId'

  many :content_templates, :in => :content_templates_ids

private

  # FIXME: This should not run after sorting
  def propagate_changes
    query_handle = self.handle #!handle_changed? ? handle : handle_was

    pages = MongoMapper.database.collection('pages')
    pages.update({
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
    }, :multi => false, :safe => true)
  end

  def propagate_self
    pages = MongoMapper.database.collection('pages')
    pages.update({
      'page_template_id' => self._root_document.id
    }, {
      '$addToSet' => {
        'data' => ContentBlock.from_template(self).to_mongo
      }
    }, :multi => false, :safe => true)
  end

end
