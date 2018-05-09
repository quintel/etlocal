module GraphAssumptions
  module_function

  def get(atlas_ds, graph, csv_row)
    nor = csv_row.editable_attributes['number_of_residences'].to_f

    scaling_factor = nor / atlas_ds.number_of_residences

    InterfaceElement.items.reject(&:flexible).map do |item|
      case item.key
      when *Atlas::Dataset::Derived.attribute_set.map(&:name)
        scale_atlas_attribute(scaling_factor, item.key, atlas_ds)
      when *Transformer::GraphMethods.all.keys
        scale_graph_default(scaling_factor, item.key, graph)
      when /^input_.+demand$/
        1
      when /^input_/
        0
      else
        # These are keys which are not used
      end
    end
  end

  def scale_atlas_attribute(factor, key, atlas_ds)
    atlas_ds.public_send(key) * factor
  end

  def scale_graph_default(factor, key, graph)
    opts = Transformer::GraphMethods.all[key]

    value_for(opts.export_method, opts.export_key, graph, factor)
  end

  def value_for(method, key, graph, factor)
    case method
    when 'demand', 'number_of_units'
      graph.node(key).get(method.to_sym) * factor
    when 'child_share', 'parent_share'
      edge = Atlas::Edge.find(key)

      if refinery_edge = graph.node(edge.supplier)
                           .edges(:out)
                           .detect{ |e| e.to.key == edge.consumer }

        refinery_edge.get(method.to_sym).to_f
      end
    end
  end
end
