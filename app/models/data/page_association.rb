class PageAssociation < Datum
  key :page_template_id, ObjectId
  key :page_id, ObjectId
  belongs_to :page

  def targets
    @targets ||= if page_template_id.present?
      Page.where(:page_template_id => page_template_id, :_id.ne => self._root_document.id)
    else
      Page.where(:_id.ne => self._root_document.id)
    end
  end

end