namespace :porthos do
  namespace :mongo do
    desc "Ensure indexes for the mongo database"
    task :ensure_indexes => :environment do
      Asset.ensure_index [[:created_at, -1]]
      Asset.ensure_index [[:updated_at, -1]]

      Page.ensure_index [['page_template_id', 1], ['data.handle', 1]]
      Page.ensure_index :updated_by_id
      Page.ensure_index [[:created_at, -1]]
      Page.ensure_index [[:updated_at, -1]]
    end

    namespace :migrate do
      desc 'Rename pages collection to items'
      task :rename_pages => :environment do
        if Page.collection.name == 'pages'
          Page.collection.rename 'items'
          puts "Pages collection is now renamed to items in #{Rails.env}"
        else
          puts "Pages collection is already renamed to items in #{Rails.env}"
        end
      end
    end
  end
end