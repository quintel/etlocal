module DatasetAnalyzer
  class NullAttributes < Base
    def analyze
      ASSUMPTIONS[:null_attributes]
    end
  end
end
