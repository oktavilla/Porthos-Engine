module Porthos
  module ActiveRecord
    module Settingable

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_settingable(options = {})
          has_many :settings, :as => :settingable, :dependent => :destroy do
            def value_for(name)
              if setting = find_by_name(name.to_s)
                setting.value
              else
                nil
              end
            end
            def to_array
              ret = {}
              find(:all).each {|setting| ret[setting.name.to_sym] = setting.value } and return ret
            end
          end

          attr_accessor :new_settings

          before_save :save_new_settings
        end
      end

    protected
      def save_new_settings
        if respond_to?(:new_settings) and new_settings and new_settings.any?
          new_settings.each do |key, value|
            if setting = settings.find_by_name(key)
              setting.update_attribute(:value, value)
            else
              settings.build(:name => key, :value => value)
            end
          end
        end
      end
    end

  end
end
