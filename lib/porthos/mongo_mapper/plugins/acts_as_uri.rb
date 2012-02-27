require 'stringex'
module Porthos
  module MongoMapper
    module Plugins
      module ActsAsUri
        extend ActiveSupport::Concern

        module ClassMethods
          def acts_as_uri(attribute, options = {})
            class_attribute :attribute_to_uriify
            class_attribute :acts_as_uri_options

            self.acts_as_uri_options = options.to_options.reverse_merge({
              :source => attribute,
              :target => 'uri',
              :duplicate_count_separator => '-',
              :only_when_blank => false
            })

            if self.acts_as_uri_options[:sync_uri]
              before_validation :generate_uri
            else
              before_validation :generate_uri, :on => :create
            end

            if embeddable?
              validate :uniqueness_of_uri_among_siblings
            else
              validation_options = {
                :case_sensitive => false,
                :allow_nil => true
              }
              validation_options[:scope] = acts_as_uri_options[:scope] if acts_as_uri_options[:scope]
              validates_uniqueness_of acts_as_uri_options[:target], validation_options
            end
          end
        end

      private
        def generate_uri
          options = self.class.acts_as_uri_options
          base_url = self.send options[:target]
          base_url = self.send(options[:source]).to_s.to_url if base_url.blank? || !options[:only_when_blank]
          write_attribute(options[:target], base_url)
        end

        def uniqueness_of_uri_among_siblings
          options = self.class.acts_as_uri_options
          current_uri = self.send options[:target]
          if _parent_document && _parent_document.send(self.model_name.tableize).one? { |s| s.id != self.id && s.send(options[:target]) == current_uri }
            errors.add(options[:target], :taken)
          end
        end
      end
    end
  end
end
