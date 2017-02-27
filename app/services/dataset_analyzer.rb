class DatasetAnalyzer
  def self.analyze(dataset_edits)
    Hash[dataset_edits.map do |key, value|
      case key
      when 'gas_consumption'
        GasConsumption.analyze(key, value)
      when 'electricity_consumption'
        ElectricityConsumption.analyze(key, value)
      when 'roof_surface_available_for_pv'
        RoofSurfaceAvailableForPV.analyze(key, value)
      when 'number_of_cars', 'number_of_inhabitants', 'number_of_residences'
        [key, value]
      else
        raise ArgumentError, "no formatter available for '#{ key }'"
      end
    end]
  end
end
