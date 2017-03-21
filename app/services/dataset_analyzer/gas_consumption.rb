module DatasetAnalyzer
  class GasConsumption < Base
    def analyze
      gas_edges.each_with_object({}) do |edge, object|
        object[edge.child.key] = edge.parent_share * total_demand_gas
      end
    end

    private

    def gas_edges
      graph.node(:households_final_demand_network_gas).edges(:out)
    end
  end
end
