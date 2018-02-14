module GraphAssumptions
  module_function

  def get(dataset, dataset_key = :nl)
    @dataset        = dataset
    @atlas_ds       = Atlas::Dataset.find(dataset_key)
    @graph          = Atlas::Runner.new(@atlas_ds).calculate
    @scaling_factor = @dataset.editable_attributes
                              .find('number_of_residences')
                              .value / @atlas_ds.number_of_residences

    scaled_area_attributes.merge(scaled_graph_values)
  end

  def scaled_area_attributes
    @atlas_ds.attributes.slice(*proportional_attributes)
      .each_with_object({}) do |(key, value), result|
        next unless value

        result[key] = scale(value)
      end
  end

  def scaled_graph_values
    Transformer::GraphMethods.all.each_with_object({}) do |(key, opts), result|
      result[key] = value_for(opts.export_method, opts.export_key)
    end
  end

  def value_for(method, key)
    case method
    when 'demand', 'number_of_units'
      scale(@graph.node(key).get(method.to_sym))
    when 'child_share', 'parent_share'
      edge = Atlas::Edge.find(key)

      if refinery_edge = @graph.node(edge.supplier)
                           .edges(:out)
                           .detect{ |e| e.to.key == edge.consumer }

        refinery_edge.get(method.to_sym).to_f
      end
    end
  end

  def scale(value)
    (value * @scaling_factor).round(2)
  end

  def proportional_attributes
    Atlas::Dataset::Derived.attribute_set
      .select{ |a| a.options[:proportional] }
      .map(&:name)
  end
end
