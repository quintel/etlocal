class DatasetAnalyzer
  class Cooling < Base
    include HeatingCooling

    def initialize(*)
      super

      @ratio_old_new_houses = ratio(:old_new_houses).fetch(:cooling)
    end

    def analyze
      to_shares.merge(
        households_useful_demand_for_cooling_new_houses:
          (total_useful_demand * @ratio_old_new_houses.fetch(:new)),
        households_useful_demand_for_cooling_old_houses:
          (total_useful_demand * @ratio_old_new_houses.fetch(:old))
      )
    end

    private

    def all_useful_demands
      {
        households_cooling_airconditioning_electricity:
          households_cooling_airconditioning_electricity,
        households_cooling_heatpump_ground_water_electricity:
          households_cooling_heatpump_ground_water_electricity
      }
    end

    def households_cooling_airconditioning_electricity
      (@analyzed_attributes.fetch(:cooling) -
        final_demand(:households_cooling_heatpump_ground_water_electricity)) *
        efficiency_for(__method__)
    end

    def households_cooling_heatpump_ground_water_electricity
      useful_demand(__method__)
    end
  end
end
