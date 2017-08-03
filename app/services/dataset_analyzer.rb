module DatasetAnalyzer
  ANALYZERS = [
    ElectricityConsumption,
    Lighting,
    Appliances,
    GasConsumption,
    Cooking,
    Cooling,
    WaterHeater,
    SpaceHeater,
    RoofSurfaceAvailableForPV,
    Transport,
    Buildings,
    Industry,
    Agriculture,
    EnergySector,
    NullAttributes,
    ToAtlasAttribute
  ].freeze

  # Overall analyze method. Analyzes a set of attributes to initializer
  # inputs and a set of values needed to create a dataset.
  #
  # Arguments:
  # - dataset       = Atlas::Dataset
  # - dataset_edits = Hash[<key> => Float]
  #
  def self.analyze(dataset, dataset_edits)
    if missing(dataset_edits).any?
      raise ArgumentError,
        "missing attributes #{ missing(dataset_edits).keys.join(', ') } for analyzes"
    end

    graph = Atlas::Runner.new(dataset).calculate

    ANALYZERS.reduce({}) do |object, analyzer|
      (ANALYZERS.last == analyzer ? {} : object).merge(analyzer.analyze(dataset, graph, dataset_edits.symbolize_keys, object))
    end
  end

  def self.missing(edits)
    Dataset::EDITABLE_ATTRIBUTES.select do |key, opts|
      opts['mandatory'] && edits[key].blank?
    end
  end
end
