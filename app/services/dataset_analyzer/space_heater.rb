module DatasetAnalyzer
  class SpaceHeater < Heater
    # - households_useful_demand_new_houses_heat_per_person
    # - households_useful_demand_old_houses_heat_per_person

    def analyze
      super.merge(
        households_useful_demand_new_houses_heat_per_person:
          (total_useful_demand * ratio_houses.fetch(:new)),
        households_useful_demand_old_houses_heat_per_person:
          (total_useful_demand * ratio_houses.fetch(:old))
      )
    end

    def key
      "space_heating"
    end
  end
end
