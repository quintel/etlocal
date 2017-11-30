class GraphAssumptions
  def self.get(dataset, dataset_key = :nl, calculated = false)
    new(dataset, dataset_key, calculated).get
  end

  def initialize(dataset, dataset_key, calculated)
    @dataset = dataset
    @atlas_ds = Atlas::Dataset.find(dataset_key)

    runner = Atlas::Runner.new(@atlas_ds)

    @graph = calculated ? runner.calculate : runner.graph
  end

  def get
    result = {}

    methods.each_pair do |key, options|
      result[key] = value_for(
        options.export_method, options.export_key
      )
    end

    result
  end

  private

  def value_for(method, key)
    case method
    when 'demand', 'number_of_units'
      scale(@graph.node(key).get(method.to_sym))
    when 'child_share', 'parent_share'
      edge = Atlas::Edge.find(key)

      edge = @graph.node(edge.supplier)
        .edges(:out)
        .detect{ |e| e.to.key == edge.consumer }

      if edge
        edge.get(method.to_sym).to_f
      end
    end
  end

  def scale(value)
    (value * scaling_factor).round(2)
  end

  def scaling_factor
    base_value = @dataset.editable_attributes
      .find('number_of_residences')
      .value

    parent_value = @atlas_ds.number_of_residences

    (base_value / parent_value)
  end

  def methods
    Transformer::GraphMethods.all
  end
end
