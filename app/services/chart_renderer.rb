class ChartRenderer
  include ActiveModel::Validations

  validates :chart_type, inclusion: { in: Chart.all.map(&:key) }

  attr_reader :chart_type

  def initialize(params)
    @chart_type = params[:type]
  end

  def data
    case @chart_type.to_sym
    when *chart_keys
      chart.options.merge(stops: stops, chart_type: @chart_type)
    when *%i(potential_heat_wko_neighborhood heat_networks bag)
      chart.options.merge(chart_type: @chart_type)
    else
      raise ArgumentError, "chart not found #{ @chart_type }"
    end
  end

  private

  def chart_keys
    Transformer::GraphMethods.all.keys
  end

  def stops
    ChartRenderer::EditableStops.for(chart)
  end

  def chart
    Chart.find(@chart_type)
  end
end
