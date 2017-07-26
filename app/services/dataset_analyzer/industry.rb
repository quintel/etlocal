module DatasetAnalyzer
  class Industry < Base
    INDUSTRY_ANALYZERS = [Individual, Nulled].freeze

    def analyze
      INDUSTRY_ANALYZERS.each_with_object({}) do |analyzer, object|
        object.merge! analyzer.analyze(@dataset, graph, @dataset_edits, @analyzed_attributes)
      end
    end
  end
end
