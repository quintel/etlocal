module Amalgamator
  class Separator < Amalgamator::Base
    def processor
      Amalgamator::Processor::Separate
    end
  end
end
