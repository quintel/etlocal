module DatasetAnalyzer
  class Appliances < Base
    APPLIANCES_KEY = :households_final_demand_for_appliances_electricity

    # Appliances division
    def analyze
      edges.each_with_object({}) do |edge, object|
        object[edge.child.key] = edge.parent_share * total_demand
      end
    end

    private

    def edges
      graph.node(APPLIANCES_KEY).edges(:out)
    end

    def total_demand
      @analyzed_attributes.fetch(APPLIANCES_KEY)
    end
  end
end
