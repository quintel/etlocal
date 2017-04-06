class ChartRenderer
  include ActiveModel::Validations

  validates :type, inclusion: { in: Chart.all.map(&:key) }

  validates :layer, inclusion: {
    in: LAYERS.fetch('chart').map { |layer| layer.fetch('name') }
  }

  attr_reader :type, :layer

  def initialize(params)
    @type  = params[:type]
    @layer = params[:layer]
  end

  def data
    case @type
    when *Dataset::EDITABLE_ATTRIBUTES.keys
      ChartRenderer::EditableStops
        .for(chart, @layer)
        .merge(layer_info: layer_info)
    end
  end

  private

  def chart
    Chart.find(@type)
  end

  def layer_info
    LAYERS.fetch('chart').detect do |layer|
      layer.fetch('name') == @layer
    end
  end
end
