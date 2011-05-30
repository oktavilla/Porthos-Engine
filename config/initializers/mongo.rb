require 'mongo_mapper'
if ENV['MONGOHQ_URL']
  MongoMapper.config = {Rails.env => {'uri' => ENV['MONGOHQ_URL']}}
else
  MongoMapper.config = {Rails.env => {'uri' => 'mongodb://localhost/porthos'}}
end
MongoMapper.connect(Rails.env)
MongoMapper.database = "porthos-#{Rails.env}"


#Asset.ensure_index :created_at
#Asset.ensure_index :updated_at

#Page.ensure_index :page_template_id
#Page.ensure_index :updated_by_id
#Page.ensure_index :created_at
#Page.ensure_index :updated_at
