module DatasetAnalyzer
  class ElectricityConsumption < Base
    # households_final_demand_electricity consists of the following edges:
    #
    # - households_final_demand_for_appliances_electricity
    # - households_final_demand_for_cooking_electricity
    # - households_final_demand_for_cooling_electricity
    # - households_final_demand_for_hot_water_electricity
    # - households_final_demand_for_lighting_electricity
    # - households_final_demand_for_space_heating_electricity
    #
    def analyze
      edges.each_with_object({}) do |edge, object|
        object[edge.child.key] = share_for(edge) * total_demand_electricity
      end
    end

    private

    def share_for(edge)
      @dataset_edits[edge.child.key.to_s] || edge.parent_share
    end

    def edges
      graph.node(:households_final_demand_electricity).edges(:out)
    end
  end
end
