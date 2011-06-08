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
  end
end