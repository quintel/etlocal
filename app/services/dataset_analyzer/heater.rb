module DatasetAnalyzer
  class Heater < Base
    def analyze
      to_shares
    end

    private

    def all_useful_demands
      @all_useful_demands ||= edges_demand
        .each_with_object(Hash.new(0)) do |(edges, total_demand), object|
          edges.each do |edge|
            object[edge.child.key] += edge.parent_share * total_demand * efficiency_for(edge.child.key)
          end
        end
    end

    def edges_demand
      top_nodes.compact.map do |node|
        [node.edges(:out), @analyzed_attributes[node.key] || node.demand]
      end
    end

    def top_nodes
      carriers.map do |carrier|
        graph.node(:"households_final_demand_for_#{ key }_#{ carrier }")
      end
    end

    def carriers
      Atlas::Carrier.all.map(&:key)
    end
  end
end
