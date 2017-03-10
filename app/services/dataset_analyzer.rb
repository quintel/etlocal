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
    unless AttributeValidator.valid?(dataset_edits)
      raise ArgumentError, "missing attributes for analyzes"
    end

    ANALYZERS.each_with_object({}) do |analyzer, object|
      object.merge! analyzer.analyze(dataset, dataset_edits, object)
    end
  end
end
