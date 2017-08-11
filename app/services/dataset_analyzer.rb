module DatasetAnalyzer
  def self.analyze(dataset, dataset_edits)
    Transformer::Caster.cast(dataset, dataset_edits)
  end
end
