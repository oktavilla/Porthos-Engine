require 'tanker'
module Porthos
  module Tanking
    module Config
      include ActiveSupport::Configurable
      config_accessor :index_name, :private_url, :public_url, :pagination_backend
    end
  end
end
