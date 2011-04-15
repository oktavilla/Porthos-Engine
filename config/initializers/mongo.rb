if ENV['MONGOHQ_URL']
  MongoMapper.config = {Rails.env => {'uri' => ENV['MONGOHQ_URL']}}
else
  MongoMapper.config = {Rails.env => {'uri' => 'mongodb://localhost/porthos'}}
end
MongoMapper.connect(Rails.env)
MongoMapper.database = "porthos-#{Rails.env}"
