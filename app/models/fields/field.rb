class Field
  include MongoMapper::EmbeddedDocument

  key :_type, String
  key :association_source_id, Integer
  key :label, String, :required => true, :unique => true
  key :handle, String, :required => true, :unique => true
  key :target_handle, String
  key :require, Boolean, :default => lambda {false}
  key :instructions, String
  key :allow_rich_text, Boolean, :default => lambda {false}
  key :relationship, String
  many :custom_attributes, :dependent => :destroy
  many :custom_associations, :dependent => :destroy
  belongs_to :field_set


  class_inheritable_accessor :data_type

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
