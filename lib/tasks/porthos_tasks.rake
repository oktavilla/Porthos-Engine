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
    end
  end
end