module DatasetAnalyzer
  class WaterHeater < Heater
    def analyze
      super.merge(households_useful_demand_hot_water: total_useful_demand)
    end

    def key
      "hot_water"
    end
  end
end
