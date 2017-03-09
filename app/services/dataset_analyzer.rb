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
    EnergySector,
    NullAttributes,
    ToAtlasAttribute,
  ].freeze

  def self.analyze(dataset_edits)
    unless AttributeValidator.valid?(dataset_edits)
      raise ArgumentError, "missing attributes for analyzes"
    end

    ANALYZERS.each_with_object({}) do |analyzer, object|
      object.merge! analyzer.analyze(dataset_edits, object)
    end
  end
end
