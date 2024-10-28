module Amalgamator
  class Combiner < Amalgamator::Base
    def processor
      Amalgamator::Processor::Combine
    end
  end
end
