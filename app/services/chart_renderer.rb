class ChartRenderer
  include ActiveModel::Validations

  validates :chart_type, inclusion: { in: Chart.all.map(&:key) }

  attr_reader :chart_type

  def initialize(params)
    @chart_type = params[:type]
  end

  def data
    case @chart_type
    when *Dataset::EDITABLE_ATTRIBUTES.keys
      chart.options.merge(stops: stops, chart_type: @chart_type, unit: unit)
    when *%w(potential_heat_wko_neighborhood heat_networks bag)
      chart.options.merge(chart_type: @chart_type)
    else
      raise ArgumentError, "chart not found #{ @chart_type }"
    end
  end

  private

  def stops
    ChartRenderer::EditableStops.for(chart)
  end

  def unit
    Dataset::EDITABLE_ATTRIBUTES[chart.key]['unit']
  end

  def chart
    Chart.find(@chart_type)
  end
end
