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
                   :through => :taggings,
                   :conditions => 'taggings.namespace IS NULL'
          has_many :all_tags, :source => :tag, :through => :taggings do
            def with_namespace(namespace)
              where("taggings.namespace = ?", namespace)
            end
          end
          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods

          options[:namespaces].each do |namespace|
            create_namespaced_tagging_methods_for namespace
          end if options[:namespaces]
        end

        def create_namespaced_tagging_methods_for(namespace)
          class_eval <<-EOV
            def #{namespace}_tag_names
              all_tags.with_namespace('#{namespace}').collect do |t|
                !t.name.include?(Tag.delimiter) ? t.name : #{'"'+'t.name'+'"'}
              end.join(Tag.delimiter)
            end

            def #{namespace}_tag_names=(tag_string)
              self.taggings.with_namespace('#{namespace}').each(&:destroy)
              self.class.tag_list_from_string(tag_string).collect(&:strip).each do |name|
                new_tag = Tag.find_or_create_by_name(name.downcase.strip)
                self.new_record? ? self.taggings.build(:tag_id => new_tag.id, :namespace => '#{namespace}') : self.taggings.create(:tag_id => new_tag.id, :namespace => '#{namespace}')
              end
            end
          EOV
        end

      end
      module SingletonMethods

        def find_tagged_with(options = {})
          tags = options.delete(:tags)
          namespace = options.delete(:namespace)
          tag_list = tags.acts_like?(String) ? tag_list_from_string(tags) : tags

          select("#{table_name}.*, count(tags.id) AS count").
          from('taggings').
          joins("join #{table_name} on #{table_name}.#{primary_key} = taggings.taggable_id
                      #{"AND taggings.taggable_type = '#{self.name}'"}
                      AND taggings.namespace #{namespace.present? ? "= '#{namespace}'" : 'IS NULL' }
                      LEFT OUTER JOIN tags ON tags.id = taggings.tag_id
                      AND LOWER(tags.name) IN ('#{tag_list.join("','")}')#{options[:joins].present? ? " #{options[:joins]}" : ''}").
          group("#{table_name}.#{primary_key} HAVING count = #{tag_list.length}").
          order(options[:order] || "#{table_name}.#{primary_key}")
        end

        def find_tags(options = {})
          namespace = options.delete(:namespace)
          Tag.select('tags.*, count(taggings.tag_id) as count').
              from('tags').
              joins('LEFT JOIN taggings ON taggings.tag_id = tags.id').
              where("taggings.taggable_type = '#{self.class.name}' and taggings.namespace #{namespace.blank? ? 'IS NULL' : "= '#{namespace}'"}").
              group('tags.id').
              order(options[:order] || 'count desc')
        end

        def find_related_tags(tag_names, options = {})
          Tag.select('select t.*, count(taggings.taggable_id) as count').from('taggings, tags').
              where("taggings.taggable_id in (
                       select taggings.taggable_id
                       from taggings, tags t
                       where taggings.tag_id = t.id
                       and (LOWER(t.name) IN ( '#{ tag_names.join("','") }' ))
                       and taggings.namespace #{options[:namespace].blank? ? 'IS NULL' : "= '#{options[:namespace]}'"}
                       group by taggings.taggable_id
                       having count(taggings.taggable_id) = #{ tag_names.size }
                     )
                     and tags.id = taggings.tag_id
                     and LOWER(tags.name) not in ( '#{ tag_names.join("','") }' )
                     and taggings.taggable_type = '#{self.class.name}'").
              group('taggings.tag_id').
              order(options[:order] || 'count desc')
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
          tags.collect do |t|
            t.name.include?(Tag.delimiter) ? "\"#{t.name}\"" : t.name
          end.join(Tag.delimiter)
        end

        def tag_names=(tag_string)
          self.taggings.each(&:destroy)
          self.class.tag_list_from_string(tag_string).collect(&:strip).each do |name|
            new_tag = Tag.find_or_create_by_name(name.downcase.strip)
            self.new_record? ? self.taggings.build(:tag_id => new_tag.id) : self.taggings.create(:tag_id => new_tag.id)
          end
        end

      end
    end
  end
end