namespace :porthos do
  namespace :mongo do
    desc "Ensure indexes for the mongo database"
    task :ensure_indexes => :environment do
      Asset.ensure_index [[:created_at, -1]]
      Asset.ensure_index [[:updated_at, -1]]

      Item.ensure_index [['page_template_id', 1], ['data.handle', 1]]
      Item.ensure_index :updated_by_id
      Item.ensure_index [[:created_at, -1]]
      Item.ensure_index [[:updated_at, -1]]

      Template.ensure_index [['_type', 1], ['position', 1]]

      Node.ensure_index :resource_id
      Node.ensure_index [['handle', 1], ['action', 1], ['controller', 1]]
      Node.ensure_index [['parent_id', 1], ['position', 1]]

      LinkList.ensure_index :handle
      LinkList.ensure_index 'links.node_id'
    end

    namespace :migrate do
      desc 'Rename pages collection to items'
      task :rename_pages => :environment do
        begin
          MongoMapper.database.collection('pages').rename('items')
          puts "Pages collection is now renamed to items in #{Rails.env}"
        rescue Mongo::MongoDBError
          puts "Pages collection is already renamed to items in #{Rails.env}"
        end
      end

      desc 'Rename content blocks to datum collections'
      task :rename_content_blocks => :environment do
        def rename_datums
          MongoMapper.database.collection('items').update({
            'data._type' => 'ContentBlock'
          }, {
            '$set' => {
              'data.$._type' => 'DatumCollection'
            }
          }, multi: true, safe: true)
        end

        def rename_templates
          MongoMapper.database.collection('templates').update({
            'datum_templates._type' => 'ContentBlockTemplate'
          }, {
            '$set' => {
              'datum_templates.$._type' => 'DatumCollectionTemplate'
            }
          }, multi: true, safe: true)
        end

        content_blocks_exists = true
        num_changed = 0
        while content_blocks_exists
          result = rename_datums
          num_changed += result['n']
          content_blocks_exists = result['updatedExisting']
        end
        puts "Renamed #{num_changed} content blocks"

        templates_exists = true
        num_changed = 0
        while templates_exists
          result = rename_templates
          num_changed += result['n']
          templates_exists = result['updatedExisting']
        end
        puts "Renamed #{num_changed} content block templates"

      end

      desc "Rename templates_id to template_ids for page associations"
      task :rename_template_id_in_page_associations => :environment do
        def find_association_templates(template_container)
          associations = []
          associations += template_container.datum_templates.find_all { |d| d.is_a?(PageAssociationTemplate) && d['page_template_id'].present? }
          find_datum_container_templates(template_container).each do |template_container|
            associations += find_association_templates(template_container)
          end
          associations
        end

        def find_datum_container_templates(template_container)
          template_container.datum_templates.find_all { |d| d.respond_to?(:datum_templates) }
        end

        def find_associations(datum_container)
          associations = []
          associations += datum_container.data.find_all { |d| d.is_a?(PageAssociation) && d['page_template_id'].present? }
          find_datum_containers(datum_container).each do |datum_container|
            associations += find_associations(datum_container)
          end
          associations
        end

        def find_datum_containers(datum)
          datum.data.find_all { |d| d.respond_to?(:data) }
        end

        Template.all.each do |template|
          template.reload
          puts "#{template.class}: #{template.label}"
          associations = find_association_templates(template)
          if associations.any?
            associations.each do |association|
              if association['page_template_id'].present?
                puts "moving page_template_id #{association['page_template_id']} to page_template_ids"
                association.page_template_ids = [association['page_template_id']]
                association['page_template_id'] = nil
              end
            end
            puts "Saved: #{template.save}"
          end
        end

        Item.all.each do |item|
          item.reload
          puts "#{item.class}: #{item.title}"
          associations = find_associations(item)
          if associations.any?
            associations.each do |association|
              if association['page_template_id'].present?
                puts "moving page_template_id #{association['page_template_id']} to page_template_ids"
                association.page_template_ids = [association['page_template_id']]
                association['page_template_id'] = nil
              end
            end
            puts "Saved: #{item.save}"
          end
        end
      end

      desc "Add datum_template_id to data"
      task :add_datum_template_id_to_data => :environment do
        Template.all.each do |template|
          puts "Updating #{template.class} #{template.label}"
          template.datum_templates.each do |datum_template|
            puts "in #{datum_template.class} #{datum_template.label}"
            if template.is_a?(PageTemplate)
              updates = datum_template.shared_attributes.inject({}) { |hash, (k, v)| hash.merge({ "data.$.#{k}" => v }) }
              puts Page.collection.update({
                'page_template_id' => template.id,
                'data.handle' => datum_template.handle
              }, {
                '$set' => updates
              }, :multi => true, :safe => true).inspect
            elsif template.is_a?(ContentTemplate)
              template.concerned_items.each do |item|
                puts "Updating #{item.class.model_name} #{item.title}"
                template.find_matching_field_sets_in_item(item).each do |field_set|
                  puts "found field set #{field_set.label}"
                  field_set.data.detect { |datum| datum.handle == datum_template.handle }.tap do |datum|
                    puts "found datum #{datum.id}"
                    puts "updating with datum_template #{datum_template.id}"
                    datum.assign(datum_template.shared_attributes) if datum
                  end
                end
                puts "Saved #{item.save}"
              end
            end
          end
        end
      end

    end
  end
end