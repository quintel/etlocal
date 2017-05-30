class GraphAssumptions
  def self.get(dataset_key = :nl, calculated = false)
    new(dataset_key, calculated).get
  end

  def initialize(dataset_key, calculated)
    dataset = Atlas::Dataset.find(dataset_key)
    runner  = Atlas::Runner.new(dataset)

    @graph  = calculated ? runner.calculate : runner.graph
  end

  def get
    nodes.compact.each_with_object({}) do |node, obj|
      obj[node.key] = edges_for(node)
    end
  end

  private

  def edges_for(node)
    Hash[node.edges(:out).map do |edge|
      [edge.child.key.to_s, edge.parent_share.to_f]
    end]
  end

  def nodes
    Dataset::EDITABLE_ATTRIBUTES
      .select { |_, opts| opts['slider_group'] }
      .keys.map do |key|
        @graph.node(key.to_sym)
      end
  end
end
