require 'tanker'
module Porthos
  module Tanker
    def self.index_name
      "#{Rails.env}_#{Porthos.app_name}".downcase
    end

    module AssetSettings
      def self.included(base)
        base.send(:include, ::Tanker)

        base.tankit Porthos::Tanker.index_name, :as => 'Asset' do
          indexes :name
          indexes :title
          indexes :description
          indexes :author
          indexes :tag_names
          indexes :hidden
        end

        base.after_save proc { |asset| Rails.env.production? ? asset.delay.update_tank_indexes : asset.update_tank_indexes }
        base.after_destroy proc { |asset| Rails.env.production? ? asset.delay.delete_tank_indexes : asset.delete_tank_indexes }
      end
    end
  end
end
