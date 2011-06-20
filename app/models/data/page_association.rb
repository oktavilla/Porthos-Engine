class PageAssociation < Datum
  key :page_template_id, ObjectId
  key :page_id, ObjectId
  belongs_to :page

  def targets
    return @targets if @targets
    exclude_ids = [self._root_document.id]
    if _parent_document.is_a?(ContentBlock)
      exclude_ids += _parent_document.data.find_all { |d| d.is_a?(PageAssociation) }.map { |d| d.page_id }
    end
    scope = Page.where(:_id.nin => exclude_ids)
    scope = scope.where(:page_template_id => page_template_id) if page_template_id.present?
    scope.published
  end

end