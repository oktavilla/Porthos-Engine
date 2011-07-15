class ParameterizeAttributeMatcher
  def initialize(attribute)
    @attribute = attribute.to_sym
  end

  def matches?(subject)
    @un_parameterized_string = 'Some Random Characters'
    subject.send("#{@attribute}=", @un_parameterized_string)
    subject.valid?
    @un_parameterized_string.parameterize == subject.send(@attribute)
  end

  def failure_message
    "Expected #{@actual_attribute} to be parameterized, \
     but got #{@actual_attribute}"
  end

  def negative_failure_message
    "Didn't expect #{@attribute} to be parameterized"
  end

  def description
    "should get parameterized"
  end
end

def parameterize_attribute(class_name)
  ParameterizeAttributeMatcher.new(class_name)
end