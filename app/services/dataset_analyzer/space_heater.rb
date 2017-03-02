class DatasetAnalyzer
  class SpaceHeater < Base
    include HeatingCooling

    KEYS = [
      :households_space_heater_heatpump_air_water_electricity,
      :households_space_heater_heatpump_ground_water_electricity,
      :households_space_heater_electricity,
      :households_space_heater_combined_network_gas
    ]

    def initialize(*)
      super

      @ratio_old_new_houses = ratio(:old_new_houses).fetch(:space_heating)
    end

    def analyze
      to_shares.merge(
        households_useful_demand_new_houses_heat_per_person:
          (total_useful_demand * @ratio_old_new_houses.fetch(:new)),
        households_useful_demand_old_houses_heat_per_person:
          (total_useful_demand * @ratio_old_new_houses.fetch(:old))
      )
    end

    private

    def all_useful_demands
      KEYS.each_with_object({}) do |key, object|
        object[key] = case key
          when :households_space_heater_electricity
            households_space_heater_electricity
          when :households_space_heater_combined_network_gas
            @analyzed_attributes.fetch(key) * efficiency_for(key)
          else
            useful_demand(key)
          end
      end
    end

    def households_space_heater_electricity
      (
        @analyzed_attributes.fetch(:space_heating) -
        final_demand(:households_space_heater_heatpump_air_water_electricity) -
        final_demand(:households_space_heater_heatpump_ground_water_electricity)
      ) * efficiency_for(__method__)
    end
  end
end
