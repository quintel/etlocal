module DatasetAnalyzer
  class Cooling < Base
    KEY = :households_final_demand_for_cooling_electricity

    def analyze
      to_shares.merge(
        households_useful_demand_for_cooling_new_houses:
          (total_useful_demand * ratio_houses.fetch(:new)),
        households_useful_demand_for_cooling_old_houses:
          (total_useful_demand * ratio_houses.fetch(:old))
      )
    end

    private

    def all_useful_demands
      @all_useful_demands ||= graph.node(KEY).edges(:out)
        .each_with_object({}) do |edge, object|
          object[edge.child.key] =
            total_demand * edge.parent_share * efficiency_for(edge.child.key)
        end
    end

    def total_demand
      @analyzed_attributes.fetch(KEY)
    end
  end
end
