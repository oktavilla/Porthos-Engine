module Porthos
  module Config
    def self.resizor(&block)
      Resizor.configure(&block)
    end

    def self.tanking
      if block_given?
        yield Porthos::Tanking::Config
      else
        Porthos::Tanking::Config
      end
    end
  end
end