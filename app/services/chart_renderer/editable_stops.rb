class ChartRenderer
  class EditableStops
    def self.for(chart, layer)
      new(chart, layer).data
    end

    def initialize(chart, layer)
      @chart    = chart
      @layer    = layer
      @gradient = Gradients.new(*@chart.color_stops)
    end

    def data
      {
        stops: stops,
        legend: {
          max: values.max,
          max_color: color_for(max),
          min: values.min,
          min_color: color_for(min),
          unit: unit
        }
      }
    end

    private

    def unit
      Dataset::EDITABLE_ATTRIBUTES[@chart.key]['unit']
    end

    def stops
      datasets.map do |dataset|
        [dataset.geo_id, color_for(scale(dataset.value.to_f))]
      end
    end

    def color_for(value)
      color = @gradient.at(((value - min) / (max - min)) * 1.0).to_s(:hex)

      "rgba(#{ color.scan(/.{2}/).map(&:hex).join(", ") }, 0.7)"
    end

    def max
      scale(values.max)
    end

    def min
      scale(values.min)
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
      @values ||= datasets.map{ |t| t.value.to_f }
    end

    def datasets
      @dataset ||=
        Dataset.public_send(@layer)
          .select("`datasets`.`geo_id`, `dataset_edits`.`key`, `dataset_edits`.`value`")
          .joins(:edits)
          .where("`dataset_edits`.`key` = ?", @chart.key)
          .group(:geo_id)
    end
  end
end
