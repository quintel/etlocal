class DatasetAnalyzer
  class ElectricityConsumption < Base
    def analyze
      ratio(:electricity).transform_values do |v|
        v * total_demand_electricity
      end
    end
  end
end
