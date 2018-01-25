class Dataset
  module Analyzer
    module_function

    def analyze!(dataset, attributes)
      atlas_dataset = Atlas::Dataset::Derived.find(dataset.temp_name)

      analyzer = Transformer::Caster.cast(attributes)

      atlas_dataset.attributes = analyzer.fetch(:area)
      atlas_dataset.save

      atlas_dataset.graph_values.values = analyzer.fetch(:graph_values).stringify_keys
      atlas_dataset.graph_values.save
    end
  end
end
