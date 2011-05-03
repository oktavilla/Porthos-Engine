require 'ostruct'
module Porthos
  module Tag
    mattr_accessor :delimiter
    self.delimiter = ' '
  end

  module Taggable
    def self.included(model)
      model.class_eval do
        extend ClassMethods
        include InstanceMethods
        key :tags, Porthos::TagsArray, :index => true
      end
    end

    module InstanceMethods
      def tag_names
        @tag_names || tags.join(Porthos::Tag.delimiter)
      end

      def tag_names=(tags_string)
        self.tags = tags_string
      end
    end

    module ClassMethods

      def tagged_with(tags)
        self.where(:tags.all => tags)
      end

      def tags_by_count(options = {})
        collection.map_reduce(self.tags_by_count_map,
                              self.tags_by_count_reduce,
                              options.merge({:raw => true, :out => { :inline => true}}))['results'].collect do |t|
                                OpenStruct.new(:name => t['_id'], :count => t['value'].to_i)
                              end.sort {|x,y| y.count <=> x.count }
      end

      def tags_by_count_map
        "function() {
          if (!this.tags) { return; }
          for (index in this.tags) { emit(this.tags[index], 1); }
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

  end

  class TagsArray
    class << self
      def to_mongo(value)
        if value.is_a?(String)
          tag_list = []
          [/\s*#{Porthos::Tag.delimiter}\s*(['"])(.*?)\1\s*/, /^\s*(['"])(.*?)\1\s*#{Porthos::Tag.delimiter}?/].each do |exp|
            value.gsub!(exp) { tag_list << $2; "" }
          end
          value.strip.split(Porthos::Tag.delimiter).collect(&:strip).uniq.compact
        else
          value
        end
      end

      def from_mongo(value)
        value || []
      end
    end
  end
end
