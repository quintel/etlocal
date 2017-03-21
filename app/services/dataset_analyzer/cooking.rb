module DatasetAnalyzer
  class Cooking < Base
    COOKING_KEY = :households_final_demand_for_cooking_electricity

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
      graph.node(COOKING_KEY).edges(:out).each_with_object({}) do |edge, object|
        object[edge.child.key] = total_demand * edge.parent_share * efficiency_for(edge.child.key)
      end
    end

    def total_demand
      @analyzed_attributes.fetch(COOKING_KEY)
    end
  end
end
