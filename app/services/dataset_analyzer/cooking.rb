module DatasetAnalyzer
  class Cooking < Base
    def analyze
      to_shares.merge(
        households_useful_demand_cooking_per_person: total_useful_demand)
    end

    private

    def all_useful_demands
      @all_useful_demands ||=
        all_useful_demands_electricity.merge(
          households_cooker_network_gas:
            @analyzed_attributes.fetch(:households_cooker_network_gas)
        )
    end

    def all_useful_demands_electricity
      total_demand = @analyzed_attributes.fetch(:cooking)

      ratio(:cooking).each_with_object({}) do |(key, cooking_ratio), object|
        object[key] = total_demand * cooking_ratio * efficiency_for(key)
      end
    end
  end
end
