class Graph
  def initialize(config)
    @graph = YAML.load_file(
      Rails.root.join('spec', 'fixtures', 'graphs', "#{ config }.yml")
    )
  end

  def build
    graph = Turbine::Graph.new

    build_nodes!(graph)
    build_edges!(graph)

    graph
  end

  private

  def build_nodes!(graph)
    @graph['nodes'].each_pair do |node, demand|
      node = Refinery::Node.new(node)
      node.set(:demand, demand)
      node.set(:model, OpenStruct.new(key: node, out_slots: [], in_slots: []))

      graph.add(node)
    end
  end

  def build_edges!(graph)
    @graph['edges'].each do |edge_attr|
      parent = graph.node(edge_attr['parent'])
      child  = graph.node(edge_attr['child'])

      key = "#{ parent.key }-#{ child.key }@#{ edge_attr['carrier'] }"

      edge = parent.connect_to(child, edge_attr['carrier'])

      # Fake an Atlas edge
      edge.set(:model, OpenStruct.new(key: key))
      edge.set(:parent_share, edge_attr['parent_share'] || 1.0)
    end
  end
end
