class Teaser < Textfield
  include MongoMapper::EmbeddedDocument
  key :asset_ids, Array, :typecast => 'ObjectId'
  has_many :assets, :in => :asset_ids

  def new_asset_id=(asset_id)
    self.asset_ids << asset_id unless asset_ids.one? { |i| i.to_s == asset_id }
  end

  def remove_asset=(asset_id)
    self.asset_ids.delete_if { |i| i.to_s == asset_id }
  end

end