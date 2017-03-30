module MapsHelper
  def layer_options
    options_for_select(LAYERS['chart'].map do |layer|
      [I18n.t("layers.#{ layer['name'] }"), layer['name']]
    end)
  end

  def display_options
    options_for_select(Chart.all.map do |chart|
      [I18n.t("charts.#{ chart.key }"), chart.key]
    end)
  end
end
