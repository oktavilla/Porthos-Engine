module Porthos
  module Tanking
    module Indexes

      def self.setup
        Porthos.config.tanking.models.each do |model_name|
          "::#{model_name}".constantize.send :include, "Porthos::Tanking::Indexes::#{model_name}".constantize
        end if Porthos.config.tanking.models
      end

      module Page
        def self.included(base)
          base.send :include, ::Tanker

          base.tankit Porthos.config.tanking.index_name do
            indexes :title
            indexes :uri
            indexes :tag_names
            indexes :data
          end

          base.after_save proc { |page| Rails.env.production? ? page.delay.update_tank_indexes : page.update_tank_indexes }
          base.after_destroy proc { |page| Rails.env.production? ? page.delay.delete_tank_indexes : page.delete_tank_indexes }
        end
      end

      module Asset
        def self.included(base)
          base.send :include, ::Tanker
          base.tankit Porthos.config.tanking.index_name, :as => 'Asset' do
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

      module ImageAsset
        def self.included(base)
          base.send :include, ::Tanker

          base.tankit Porthos.config.tanking.index_name, :as => 'Asset' do
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
end