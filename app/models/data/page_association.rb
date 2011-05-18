class PageAssociation < Datum
  key :page_template_id, ObjectId
  key :page_id, ObjectId
  belongs_to :page

  def targets
    @targets ||= [].tap do |targets|
      if page_template_id.present?
        targets.replace Page.where(:page_template_id => page_template_id).all
      else
        targets.replace Page.all
      end
    end
  end

end