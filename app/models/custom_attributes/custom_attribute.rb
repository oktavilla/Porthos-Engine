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
    @value = read_attribute(self.value_attribute)
    @value.present? && @value.acts_like?(String) ? @value.html_safe : @value
  end

protected

  def parameterize_handle
    self.handle = handle.parameterize if handle.present?
  end

end