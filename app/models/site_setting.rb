class SiteSetting
  include MongoMapper::Document
  validates_presence_of :name
  validates_uniqueness_of :name

  class << self
    def value_for(setting_name)
      SiteSetting.find_or_create_by_name(setting_name.to_s).value
    end
  end
end
