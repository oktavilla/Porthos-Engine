module Porthos
  module Config
    include ActiveModel::Observing
    extend self

    def resizor(&block)
      Resizor.configure(&block)
    end

    def tanking
      if block_given?
        yield Porthos::Tanking::Config
      else
        Porthos::Tanking::Config
      end
    end
  end
end