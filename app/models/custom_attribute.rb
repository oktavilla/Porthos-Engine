class CustomAttribute < ActiveRecord::Base
  class_inheritable_accessor :value_attribute

  belongs_to :context,
             :polymorphic => true,
             :touch => true

  belongs_to :field

  before_validation :parameterize_handle

  def value=(value)
    write_attribute(self.value_attribute, value)
  end

  def value
    read_attribute(self.value_attribute)
  end

protected

  def parameterize_handle
    self.handle = handle.parameterize
  end

end