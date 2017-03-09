module DatasetAnalyzer
  module HeatingCooling
    def useful_demand(key)
      final_demand(key) * efficiency_for(key)
    end

    def final_demand(key)
      demand(:heatpump).fetch(key) * number_of_residences
    end

    def ratio_houses
      {
        old: number_of_old_residences / number_of_residences,
        new: number_of_new_residences / number_of_residences
      }
    end
  end
end
