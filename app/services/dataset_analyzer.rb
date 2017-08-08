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
    validator = AttributeValidator.new(dataset_edits)

    unless validator.valid?
      raise ArgumentError,
        "missing attributes #{ validator.message } for analyzes"
    end

    graph = Atlas::Runner.new(dataset).calculate

    ANALYZERS.reduce({}) do |object, analyzer|
      (ANALYZERS.last == analyzer ? {} : object).merge(analyzer.analyze(dataset, graph, dataset_edits.symbolize_keys, object))
    end
  end
end
