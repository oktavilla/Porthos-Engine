require 'ostruct'

module Porthos
  class Tag
    include MongoMapper::EmbeddedDocument
    key :name, String
    key :namespace, String
  end

  module Taggable
    mattr_accessor :delimiter
    self.delimiter = ' '

    module Plugin
      extend ActiveSupport::Concern

      module ClassMethods

        def taggable(_options = {})
          has_many :tags, :class_name => 'Porthos::Tag'
          ensure_index 'tags.name'
          class_eval <<-EOV
            def assign_with_read_write_tag_names(attrs={})
              attrs.each do |key, value|
                if _match = match_tag_names_methods(key)
                  self.send(_match[2]+'=', value, _match[1])
                  attrs.delete(key)
                end
              end
              assign_without_read_write_tag_names(attrs)
            end
            alias_method_chain :assign, :read_write_tag_names
          EOV
        end

        def tagged_with(tags_list, options = {})
          namespace = options.delete(:namespace)
          self.where(:'tags.name'.all => tags_list, :'tags.namespace' => namespace)
        end

        def tags_by_count(_options = {})
          namespace = _options.delete(:namespace)
          options = {:raw => true, :out => { :inline => true}, :query => {:'tags.namespace' => namespace}}.merge(_options)
          response = collection.map_reduce(self.tags_by_count_map, self.tags_by_count_reduce, options)
          response['results'].collect do |t|
            OpenStruct.new(:name => t['_id'], :count => t['value'].to_i)
          end.sort {|x,y| y.count <=> x.count }
        end

        def tags_by_count_map
          "function() {
              if (!this.tags) { return; }
              for (index in this.tags) { emit(this.tags[index].name, 1); }
            }"
        end

        def tags_by_count_reduce
          "function(previous, current) {
              var count = 0;
              for (index in current) { count += current[index]; }
              return count;
            }"
        end

      end

      module InstanceMethods
        def method_missing_with_read_write_tag_names(method, *args)
          if _match = match_tag_names_methods(method)
            self.send(_match[2].to_sym, *(args << _match[1]))
          else
            method_missing_without_read_write_tag_names(method, *args)
          end
        end
        alias_method_chain :method_missing, :read_write_tag_names

        def tag_names(namespace = nil)
          tags.find_all{|t| t.namespace == namespace}.collect{|tag| tag.name.include?(Porthos::Taggable.delimiter) ? "\"#{tag.name}\"" : tag.name}.join(Porthos::Taggable.delimiter)
        end

        def tag_names=(in_tags, namespace = nil)
          tags_array = in_tags.is_a?(String) ? split_tags(in_tags) : in_tags
          self.tags.delete_if{|t| t.namespace == namespace}
          self.tags += tags_array.collect { |tag_name| Porthos::Tag.new(:name => tag_name, :namespace => namespace)}
        end

      protected
        def split_tags(value)
          tag_list = []
          [/\s*#{Porthos::Taggable.delimiter}\s*(['"])(.*?)\1\s*/, /^\s*(['"])(.*?)\1\s*#{Porthos::Taggable.delimiter}?/].each do |exp|
            value.gsub!(exp) { tag_list << $2; "" }
          end
          tag_list + value.strip.split(Porthos::Taggable.delimiter).collect(&:strip).uniq.compact
        end

        def match_tag_names_methods(possible_method_name)
          possible_method_name.to_s.match(/(.*)_(tag_names=|tag_names)$/)
        end
      end
    end
  end
end

MongoMapper::Document.plugin(Porthos::Taggable::Plugin)
