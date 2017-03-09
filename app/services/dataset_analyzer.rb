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
    raise ArgumentError unless valid_edits?(dataset_edits)

    ANALYZERS.each_with_object({}) do |analyzer, object|
      object.merge! analyzer.analyze(dataset_edits, object)
    end
  end

  private

  def self.valid_edits?(dataset_edits)
    Dataset::EDITABLE_ATTRIBUTES.keys.all? do |key|
      dataset_edits[key].present? && dataset_edits[key].is_a?(Numeric)
    end
  end
end
