class ChartRenderer
  class ColorGenerator
    OPACITY = 0.7
    LEGEND_ITEMS_COUNT = 5

    def initialize(chart, datasets)
      @chart    = chart
      @datasets = datasets
      @gradient = Gradients.new(*@chart.color_stops)
    end

    def generate
      {
        stops: stops,
        legend: {
          scale: @chart.scale,
          bars: bars
        }
      }
    end

    private

    def bars
      step = ((values.max - values.min) / LEGEND_ITEMS_COUNT).floor

      (values.min...values.max).step(step).map do |val|
        { min:   val.round(2),
          max:   (val + step).round(2),
          color: color_for(scale(val)).join(',') }
      end
    end

    def stops
      @datasets.each_with_object({}) do |dataset, object|
        object[dataset.chart_id] = color_for(scale(dataset.value.to_f))
      end
    end

    def color_for(value)
      color = @gradient.at(((value - min) / (max - min)) * 1.0).to_s(:hex)

      color.scan(/.{2}/).map(&:hex) << OPACITY
    end

    def max
      @max ||= scale(values.max)
    end

    def min
      @min ||= scale(values.min)
    end

    def scale(value)
      case @chart.scale
      when 'log10'
        Math.log10(value.zero? ? value + 1 : value)
      else
        value
      end
    end

    def values
      @values ||= @datasets.map{ |t| t.value.to_f }
    end
  end
end
