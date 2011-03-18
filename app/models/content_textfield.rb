class ContentTextfield < ActiveRecord::Base
  include Porthos::ContentResource
  
  has_many :contents,
           :as => :resource
  validates_presence_of :body,
                        :on => :update
  
  @@filters = %w(wymeditor html textile)
  @@default_filter = 'wymeditor'
  cattr_accessor :filters
  cattr_accessor :default_filter
  
  def filter
    @filter ||= read_attribute(:filter) || default_filter
  end
  
end
