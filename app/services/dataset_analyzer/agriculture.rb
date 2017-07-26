module DatasetAnalyzer
  class Agriculture < Base
    AGRICULTURE_ANALYZERS = [Individual, Nulled].freeze

    def analyze
      AGRICULTURE_ANALYZERS.each_with_object({}) do |analyzer, object|
        object.merge! analyzer.analyze(@dataset, graph, @dataset_edits, @analyzed_attributes)
      end
    end
  end
end
