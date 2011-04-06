class CustomAssociation < ActiveRecord::Base
  belongs_to :context,
             :polymorphic => true,
             :touch => true

  belongs_to :target,
             :polymorphic => true,
             :touch => true

  belongs_to :field

  validates_presence_of :target_id,
                        :field_id,
                        :handle,
                        :relationship

  scope :with_field, lambda { |field_id|
    where('field_id = ?', field_id)
  }

  before_validation :parameterize_handle

  resort!

  def siblings
    self.class.where(:context_type => context_type, :context_id => context_id, :handle => handle)
  end

protected

  def parameterize_handle
    self.handle = handle.parameterize if handle.present?
  end

end