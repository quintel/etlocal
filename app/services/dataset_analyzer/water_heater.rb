module DatasetAnalyzer
  class WaterHeater < Base
    include HeatingCooling

    KEYS = [
      :households_water_heater_heatpump_air_water_electricity,
      :households_water_heater_heatpump_ground_water_electricity,
      :households_water_heater_resistive_electricity,
      :households_water_heater_combined_network_gas
    ]

    def analyze
      to_shares.merge(households_useful_demand_hot_water: total_useful_demand)
    end

    private

    def all_useful_demands
      @all_useful_demands ||= begin
        KEYS.each_with_object({}) do |key, object|
          object[key] = case key
            when :households_water_heater_combined_network_gas
              households_water_heater_combined_network_gas
            when :households_water_heater_resistive_electricity
              households_water_heater_resistive_electricity
            else
              useful_demand(key)
            end
        end
      end
    end

    def households_water_heater_combined_network_gas
      @analyzed_attributes.fetch(:households_final_demand_for_hot_water_network_gas) * efficiency_for(__method__)
    end

    # Public: puts the rest of the final demand to the
    # water_heater_resistive_electricity converter.
    def households_water_heater_resistive_electricity
      (
        @analyzed_attributes.fetch(:households_final_demand_for_hot_water_electricity) -
        final_demand(:households_water_heater_heatpump_air_water_electricity) -
        final_demand(:households_water_heater_heatpump_ground_water_electricity)
      ) * efficiency_for(__method__)
    end
  end
end
