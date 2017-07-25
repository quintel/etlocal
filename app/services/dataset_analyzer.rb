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
    EnergySector,
    NullAttributes,
    ToAtlasAttribute,
  ].freeze

  # Overall analyze method
  #
  # Arguments:
  # - dataset       = Atlas::Dataset::Derived
  # - dataset_edits = Hash[<key> => Float]
  #
  def self.analyze(dataset, dataset_edits)
    if missing(dataset_edits).any?
      raise ArgumentError,
        "missing attributes #{ missing(dataset_edits).keys.join(', ') } for analyzes"
    end

    ANALYZERS.each_with_object({}) do |analyzer, object|
      object.merge! analyzer.analyze(dataset, dataset_edits.symbolize_keys, object)
    end
  end

  def self.missing(edits)
    Dataset::EDITABLE_ATTRIBUTES.select do |key, opts|
      opts['mandatory'] && edits[key].blank?
    end
  end
end
