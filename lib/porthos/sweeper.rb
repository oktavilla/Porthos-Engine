module Porthos
  module Sweeper
    def self.included(base)
      base.send :cache_sweeper, :pages_sweeper, :only => [ :create, :update, :destroy, :sort, :publish ]
    end
  end
end
