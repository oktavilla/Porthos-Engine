module Porthos
  module MongoMapper
    module Callbacks
      CALLBACKS = [
        :before_validation, :after_validation,
        :before_create, :after_create,
        :before_destroy, :after_destroy,
        :before_save, :after_save,
        :before_update, :after_update
      ]
    end
  end
end