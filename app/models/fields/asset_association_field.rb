class AssetAssociationField < AssociationField
  validates_presence_of :relationship
  self.data_type = CustomAssociation

  def possible_targets
    @possible_targets ||= connection.select_all("SELECT id, title FROM assets ORDER BY title")
  end

  def target_type
    @target_type ||= target_class.to_s.downcase
  end

  def target_class
    self.class.target_class
  end

  def self.target_class
    Asset
  end
end