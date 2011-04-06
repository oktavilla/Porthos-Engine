class Field < ActiveRecord::Base
  class_inheritable_accessor :data_type

  resort!

  def siblings
    self.field_set.fields
  end

  belongs_to :field_set

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
    self.handle = handle.parameterize if handle.present?
  end

  def not_a_reserved_handle
    errors.add(:handle, I18n.t(:reserved, :scope => :'activerecord.errors.models.field.handle')) if handle.present? && Page.new.respond_to?(handle)
  end

end