class AssetAssociationTemplate < DatumTemplate
  key :allowed_asset_filetypes, Array, default: -> { [] }
end
