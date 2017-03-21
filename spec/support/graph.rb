class Graph
  def initialize(config)
    @graph = YAML.load_file(
      Rails.root.join("spec", "fixtures", "graphs", "#{ config }.yml")
    )
  end

  def build
    graph = Turbine::Graph.new

    @graph['nodes'].each_pair do |node, demand|
      node = Refinery::Node.new(node)
      node.set(:demand, demand)

      graph.add(node)
    end

    @graph['edges'].each do |edge_attr|
      parent = graph.node(edge_attr['parent'])
      child  = graph.node(edge_attr['child'])

      edge = parent.connect_to(child, edge_attr['carrier'])

      edge.set(:parent_share, edge_attr['parent_share'] || 1.0)
    end

    graph
  end
end
