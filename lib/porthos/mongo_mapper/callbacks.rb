module Porthos
  module MongoMapper
    module Callbacks
      CALLBACKS = [
        :before_validation, :after_validation,
        :after_initialize,
        :before_create, :around_create, :after_create,
        :before_destroy, :around_destroy, :after_destroy,
        :before_save, :around_save, :after_save,
        :before_update, :around_update, :after_update,
      ]
    end
  end
end