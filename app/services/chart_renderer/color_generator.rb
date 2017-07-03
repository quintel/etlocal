class ChartRenderer
  class ColorGenerator
    OPACITY = 0.7

    def initialize(chart, datasets)
      @chart    = chart
      @datasets = datasets
      @gradient = Gradients.new(*@chart.color_stops)
    end

    def generate
      {
        stops: stops#,
        #legend: {
        #  max: values.max,
        #  max_color: color_for(max),
        #  min: values.min,
        #  min_color: color_for(min),
        #  unit: unit
        #}
      }
    end

    private

    def unit
      Dataset::EDITABLE_ATTRIBUTES[@chart.key]['unit']
    end

    def stops
      @datasets.each_with_object({}) do |dataset, object|
        object[dataset.chart_id] = color_for(dataset.value.to_f)
      end
    end

    def color_for(value)
      value = scale(value)
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
