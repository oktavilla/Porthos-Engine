class CustomAssociationProxy
  include Enumerable
  alias_method :proxy_respond_to?, :respond_to?

  attr_accessor :target_ids,
                :target_class

  def initialize(options)
    self.target_ids = options[:target_ids]
    self.target_class = options[:target_class]
    @loaded = false
  end

  # Has the \target been already \loaded?
  def loaded?
    @loaded
  end

  # Asserts the \target has been loaded setting the \loaded flag to +true+.
  def loaded
    @loaded = true
  end

  def target
    @target
  end

  def target=(target)
    @target = target
    loaded
  end

  def size
    !loaded? ? count : load_target.size
  end

  def empty?
    size.zero?
  end

  def any?
    !empty?
  end

  def length
    load_target.size
  end

  def count
    with_scope(construct_scope) do
      target_class.count
    end
  end

  def each
    load_target unless loaded?
    target.each { |*p| yield *p }
  end

  # Does the proxy or its \target respond to +symbol+?
  def respond_to?(*args)
    proxy_respond_to?(*args) || (load_target && @target.respond_to?(*args))
  end

  def proxy_respond_to?(method, include_private = false)
    super || target_class.respond_to?(method, include_private)
  end

  # Forwards +with_scope+ to the target_class.
  def with_scope(*args, &block)
    target_class.send :with_scope, *args, &block
  end

protected

  def method_missing(method, *args)
    if @target.respond_to?(method) || (!target_class.respond_to?(method) && Class.respond_to?(method))
      if block_given?
        super { |*block_args| yield(*block_args) }
      else
        super
      end
    elsif target_class.scopes.include?(method)
      target_class.scopes[method].call(self, *args)
    else
      with_scope(construct_scope) do
        if block_given?
          target_class.send(method, *args) { |*block_args| yield(*block_args) }
        else
          target_class.send(method, *args)
        end
      end
    end
  end
  
  def load_target
    if !loaded?
      self.target = find_target
    end
  end
  
  def find_target
    with_scope(construct_scope) do
      target_class.find(:all)
    end
  end
  
  def construct_scope
    { :find => {
      :conditions => "id IN(#{target_ids.join(',')})"
    }}
  end
    
end