module ActiveRecord
  module Acts
    module Taggable
      def self.included(base)
        base.extend(ClassMethods)  
      end

      module ClassMethods
        def acts_as_taggable(options = {})
          has_many :taggings,
                   :as => :taggable,
                   :dependent => :destroy
          has_many :tags,
                   :through => :taggings
          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods
        end
        
      end
      module SingletonMethods
      
        def find_tagged_with(options = {})
          tags = options.delete(:tags)
          tag_list = tags.is_a?(String) ? tag_list_from_string(tags) : tags
          find(:all, options.merge({
            :select => "#{table_name}.*, count(tags.id) AS count",
            :from   => "taggings",
            :joins  => "join #{table_name} on #{table_name}.#{primary_key} = taggings.taggable_id
                        #{"AND taggings.taggable_type = '#{self.name}'"}
                        LEFT OUTER JOIN tags ON tags.id = taggings.tag_id
                        AND LOWER(tags.name) IN ('#{tag_list.join("','")}')",
            :group  => "#{table_name}.#{primary_key} HAVING count = #{tag_list.length}",
            :order  => options[:order] || "#{table_name}.#{primary_key}"
          }))
        end
        
        def find_tags(options = {})
          Tag.find(:all, options.merge({
            :select     => 'tags.*, count(taggings.tag_id) as count',
            :from       => 'tags',
            :joins      => 'LEFT JOIN taggings ON taggings.tag_id = tags.id',
            :conditions => "taggings.taggable_type = '#{self.name}' ",
            :group      => 'tags.id',
            :order      => options[:order] || 'count desc'
          }))
        end

        def find_related_tags(tag_names, options = {})
          sql = " select t.*, count(taggings.taggable_id) as count
                  from taggings, tags t 
                  where taggings.taggable_id
                  in ( select taggings.taggable_id
                       from taggings, tags t
                       where taggings.tag_id = t.id and (LOWER(t.name) IN ( '#{ tag_names.join("','") }' )) 
                       group by taggings.taggable_id 
                       having count(taggings.taggable_id) = #{ tag_names.size } ) 
                  and t.id = taggings.tag_id 
                  and LOWER(t.name) not in ( '#{ tag_names.join("','") }' )
                   and taggings.taggable_type = '#{self.class_name}'
                  group by taggings.tag_id 
                  order by #{ options[:order] || 'count desc' }"
          Tag.find_by_sql(sql)
        end
      
        def tag_list_from_string(string)
          tag_list = []
          [/\s*#{Tag.delimiter}\s*(['"])(.*?)\1\s*/, /^\s*(['"])(.*?)\1\s*#{Tag.delimiter}?/].each do |exp|
            string.gsub!(exp) { tag_list << $2; "" }
          end
          tag_list += string.strip.split(Tag.delimiter).uniq.compact
        end
      end
      
      module InstanceMethods
        
        def tag_names
          tags.collect {|t| t.name.include?(Tag.delimiter) ? "\"#{t.name}\"" : t.name }.join(Tag.delimiter)
        end
        
        def tag_names=(tag_string)
          self.taggings.clear
          self.class.tag_list_from_string(tag_string).collect(&:strip).each do |name|
            new_tag = Tag.find_or_create_by_name(name.downcase.strip)
            self.new_record? ? self.taggings.build(:tag_id => new_tag.id) : self.taggings.create(:tag_id => new_tag.id)
          end
          tags.reload
        end
        
      end
    end
  end
end