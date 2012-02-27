require 'ostruct'

module Porthos
  module MongoMapper
    class Tag
      include ::MongoMapper::EmbeddedDocument
      key :name, String
      key :namespace, String, :default => nil
    end

    module Plugins

      module Taggable
        mattr_accessor :delimiter
        self.delimiter = ' '

        module Plugin
          extend ActiveSupport::Concern

          module ClassMethods

            def taggable(_options = {})
              has_many :_tags, :class_name => 'Porthos::MongoMapper::Tag'
              after_save :cache_tags_if_changed

              class_eval <<-EOV
                def attributes_with_read_write_tag_names=(attrs={})
                  attrs.each do |key, value|
                    if _match = match_tag_names_methods(key)
                      self.send(_match[2]+'=', value, _match[1])
                      attrs.delete(key)
                    end
                  end if attrs
                  self.attributes_without_read_write_tag_names=(attrs)
                end
                alias_method_chain :attributes=, :read_write_tag_names
              EOV
            end

            def tagged_with(tags_list, options = {})
              namespace = options.delete(:namespace)
              self.where(:'_tags.name'.all => tags_list, :'_tags.namespace' => namespace)
            end

            def all_tags_collection_name
              "#{self.name}_tags".downcase
            end

            def cache_tags!
              options = { :raw => true, :out => { :merge => all_tags_collection_name } }
              collection.map_reduce(self.tags_with_count_map, self.tags_with_count_reduce, options)
            end

            def all_tags(selector = {}, options = {})
              database[all_tags_collection_name].find(selector, options).collect do |tag|
                OpenStruct.new({
                  :name => tag['value']['name'],
                  :count => tag['value']['count'].to_i,
                  :namespace => tag['value']['namespace']
                })
              end
            end

            def tags_by_count(options = {})
              all_tags({
                  :'value.namespace' => options.delete(:namespace)
                }.merge(options),
                {
                  :sort => ['value.count', :desc]
                })
            end

            def tags_with_count_map
              "function() {
                 if (!this._tags) { return; }
                 for (index in this._tags) {
                   emit(this._tags[index].name+this._tags[index].namespace, {
                     count: 1,
                     name: this._tags[index].name,
                     namespace: (this._tags[index].namespace||null)
                   });
                 }
               }"
            end

            def tags_with_count_reduce
              "function(previous, current) {
                 var result = {count: 0, name: '', namespace: null}
                 for (index in current) {
                   result.count += current[index].count;
                   result.name = current[index].name;
                   result.namespace = (current[index].namespace||null);
                 }
                 return result;
               }"
            end
          end

          def method_missing_with_read_write_tag_names(method, *args)
            if _match = match_tag_names_methods(method)
              self.send(_match[2].to_sym, *(args << _match[1]))
            else
              method_missing_without_read_write_tag_names(method, *args)
            end
          end
          alias_method_chain :method_missing, :read_write_tag_names

          def tags(namespace = nil)
            _tags.find_all { |t| t.namespace == namespace }
          end

          def tag_names(namespace = nil)
            tags(namespace).collect { |tag| tag.name.include?(Porthos::MongoMapper::Plugins::Taggable.delimiter) ? "\"#{tag.name}\"" : tag.name }.join(Porthos::MongoMapper::Plugins::Taggable.delimiter)
          end

          def tag_names=(in_tags, namespace = nil)
            tags_array = in_tags.is_a?(String) ? split_tags(in_tags) : in_tags
            self._tags.delete_if{ |t| t.namespace == namespace }
            self._tags += tags_array.collect do |tag_name|
              Porthos::MongoMapper::Tag.new(:name => tag_name, :namespace => namespace)
            end
            @tags_changed = true
          end

          def tags_changed?
            @tags_changed
          end

          protected
          def split_tags(value)
            tag_list = []
            [/\s*#{Porthos::MongoMapper::Plugins::Taggable.delimiter}\s*(['"])(.*?)\1\s*/, /^\s*(['"])(.*?)\1\s*#{Porthos::MongoMapper::Plugins::Taggable.delimiter}?/].each do |exp|
              value.gsub!(exp) { tag_list << $2; "" }
            end
            tag_list + value.strip.split(Porthos::MongoMapper::Plugins::Taggable.delimiter).collect(&:strip).uniq.compact
          end

          def match_tag_names_methods(possible_method_name)
            possible_method_name.to_s.match(/(.*)_(tag_names=|tag_names)$/)
          end

          def cache_tags_if_changed
            if tags_changed?
              Rails.env.production? ? self.class.delay.cache_tags! : self.class.cache_tags!
            end
          end
        end
      end
    end
  end
end
