class Field < ActiveRecord::Base
  class_inheritable_accessor :data_type

  has_many :custom_attributes,
           :dependent => :destroy
           
  has_many :custom_associations,
           :dependent => :destroy
  
  validates_uniqueness_of :label,
                          :handle,
                          :scope => :field_set_id

  validates_presence_of :field_set_id,
                        :label,
                        :handle

  before_validation :parameterize_handle
  
  validate :not_a_reserved_handle
  
  acts_as_list :scope => :field_set_id

  class << self

    def types
      [
        StringField,
        TextField,
        DateTimeField,
        BooleanField,
        PageAssociationField,
        ReversedPageAssociationField,
        AssetAssociationField
      ]
    end

  end

protected

  def parameterize_handle
    self.handle = handle.parameterize
  end
  
  def not_a_reserved_handle
    errors.add(:handle, I18n.t(:reserved, :scope => :'activerecord.errors.models.field.handle')) if Page.new.respond_to?(handle)
  end
  
end