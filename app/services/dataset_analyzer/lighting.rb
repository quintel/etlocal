module DatasetAnalyzer
  class Lighting < Base
    LIGHTING_KEY = :households_final_demand_for_lighting_electricity

    def analyze
      to_shares.merge(households_useful_demand_lighting: total_useful_demand)
    end

    def all_useful_demands
      @all_useful_demands ||= graph.node(LIGHTING_KEY).edges(:out)
        .each_with_object({}) do |edge, object|
          object[edge.child.key] = total_demand * edge.parent_share * efficiency_for(edge.child.key)
        end
    end

    private

    def total_demand
      @analyzed_attributes.fetch(LIGHTING_KEY)
    end
  end
end
