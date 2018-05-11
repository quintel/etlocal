class GraphAssumptions
  PROPORTIONAL_ATTRIBUTES = Atlas::Dataset::Derived.attribute_set
    .select { |a| a.options[:proportional] }

  NON_PROPORTIONAL_ATTRIBUTES = Atlas::Dataset::Derived.attribute_set
    .select { |a| !a.options[:proportional] }

  def self.get(atlas_ds, graph, csv_row)
    new(atlas_ds, graph, csv_row).get
  end

  def initialize(atlas_ds, graph, csv_row)
    @atlas_ds = atlas_ds
    @graph = graph
    @number_of_residences = csv_row['number_of_residences'].to_f
  end

  def get
    InterfaceElement.items.reject(&:skip_validation).map do |item|
      case item.key
      when *PROPORTIONAL_ATTRIBUTES.map(&:name)
        @atlas_ds.public_send(item.key) * factor
      when *NON_PROPORTIONAL_ATTRIBUTES.map(&:name)
        @atlas_ds.public_send(item.key)
      when *Transformer::GraphMethods.all.keys
        scale_graph_default(item)
      when /^input_.+demand$/
        1
      when /^input_/
        0
      end
    end
  end

  private

  def factor
    @factor ||= @number_of_residences / @atlas_ds.number_of_residences
  end

  def scale_graph_default(item)
    opts = Transformer::GraphMethods.all[item.key]

    case opts.export_method
    when 'demand', 'number_of_units'
      @graph.node(opts.export_key).get(opts.export_method.to_sym) * factor
    when 'child_share', 'parent_share'
      edge = Atlas::Edge.find(opts.export_key)

      if refinery_edge = @graph.node(edge.supplier)
                           .edges(:out)
                           .detect{ |e| e.to.key == edge.consumer }

        if item.flexible
          total = @graph.node(edge.supplier).edges(:out).sum do |e|
            if e.to.key == edge.consumer
              0
            else
              e.get(opts.export_method.to_sym).round(2)
            end
          end

          (1 - total).to_f.round(2)
        else
          refinery_edge.get(opts.export_method.to_sym).to_f.round(2)
        end
      end
    end
  end
end
