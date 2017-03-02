class DatasetAnalyzer
  module HeatingCooling
    def useful_demand(key)
      final_demand(key) * efficiency_for(key)
    end

    def final_demand(key)
      demand(:heatpump).fetch(key) * number_of_residences
    end
  end
end
