class ChartRenderer
  include ActiveModel::Validations

  validates :type, inclusion: { in: Chart.all.map(&:key) }

  attr_reader :type

  def initialize(params)
    @type = params[:type]
  end

  def data
    case @type
    when *Dataset::EDITABLE_ATTRIBUTES.keys
      { layers: chart.layers,
        stops: stops }
    when 'potential_heat_wko_neighborhood'
      { layers: chart.layers }
    else
      raise ArgumentError, "chart not found #{ @type }"
    end
  end

  private

  def stops
    ChartRenderer::EditableStops.for(chart)
  end

  def chart
    Chart.find(@type)
  end
end
