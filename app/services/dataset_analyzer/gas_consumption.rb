module DatasetAnalyzer
  class GasConsumption < Base
    def initialize(*)
      super

      @ratio_cooking = ratio(:cooking_carriers)
      @ratio_heating = ratio(:water_heater_space_heater_gas)
    end

    def analyze
      {
        households_cooker_network_gas:
          households_cooker_network_gas,
        households_water_heater_combined_network_gas:
          (gas_min_cooking * @ratio_heating.fetch(:water_heater)),
        households_space_heater_combined_network_gas:
          (gas_min_cooking * @ratio_heating.fetch(:space_heater))
      }
    end

    private

    def households_cooker_network_gas
      (@analyzed_attributes.fetch(:cooking) / @ratio_cooking.fetch(:electricity)) *
        @ratio_cooking.fetch(:gas) *
        efficiency_for(:households_cooker_network_gas)
    end

    def gas_min_cooking
      (total_demand_gas - households_cooker_network_gas)
    end
  end
end
