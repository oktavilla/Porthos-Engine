class PageAssociation < Datum
  key :page_template_ids, Array, typecast: 'ObjectId'
  key :page_id, ObjectId
  belongs_to :page
  belongs_to :item, :foreign_key => :page_id

  def page_template_id=(page_template_id)
    @page_template_id = page_template_id
    page_template_ids << @page_template_id
  end

  def page_template_id
    @page_template_id
  end

  def targets
    return @targets if @targets
    exclude_ids = [self._root_document.id]
    if _parent_document.is_a?(DatumCollection)
      exclude_ids += _parent_document.data.find_all { |d| d != self && d.is_a?(PageAssociation) }.map { |d| d.page_id }
    end
    scope = Item.fields(:_id, :title).where(:_id.nin => exclude_ids)
    scope = scope.where(:page_template_id.in => page_template_ids) if page_template_ids && page_template_ids.any?
    scope.published
  end

end
