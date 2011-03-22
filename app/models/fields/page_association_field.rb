class PageAssociationField < Field
  validates_presence_of :relationship
  self.data_type = CustomAssociation

  def possible_targets
    sql  = 'SELECT id, title FROM pages'
    sql += " WHERE field_set_id = #{association_source_id}" unless association_source_id.blank?
    sql += " ORDER BY title"
    @possible_targets ||= connection.select_all(sql)
  end

  def target_type
    @target_type ||= target_class.to_s.downcase
  end

  def target_class
    self.class.target_class
  end

  def self.target_class
    Page
  end

end