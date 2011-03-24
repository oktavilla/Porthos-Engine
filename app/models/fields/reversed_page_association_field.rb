class ReversedPageAssociationField < AssociationField
  validates_presence_of :target_handle
end