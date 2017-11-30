class ChartRenderer
  class EditableStops
    def self.for(chart)
      new(chart).data
    end

    def initialize(chart)
      @chart = chart
    end

    def data
      datasets.group_by(&:group).each_with_object({}) do |(group, datasets), object|
        object[group] = ColorGenerator.new(@chart, datasets).generate
      end
    end

    private

    def datasets
      @dataset ||= Dataset
        .select("`datasets`.`geo_id`, `dataset_edits`.`key`, `dataset_edits`.`value`")
        .joins(:edits)
        .where("`dataset_edits`.`key` = ?", @chart.editable_key)
        .group(:geo_id)
    end
  end
end
