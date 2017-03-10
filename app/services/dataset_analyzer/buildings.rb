module DatasetAnalyzer
  class Buildings < Base
    BUILDING_NODES = %i(
      buildings_useful_demand_for_appliances
      buildings_useful_demand_cooling
      buildings_useful_demand_for_space_heating
      buildings_useful_demand_light
    )

    def analyze
      BUILDING_NODES.each_with_object({}) do |key, object|
        object[key] = graph.node(key).demand * ratio
      end
    end

    private

    def ratio
      return 0.0 if @dataset.number_of_buildings.zero?

      number_of_buildings / @dataset.number_of_buildings
    end

    def number_of_buildings
      building_area * conversion(:m2_to_no)
    end
  end
end
