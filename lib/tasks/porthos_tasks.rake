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
    end
  end
end