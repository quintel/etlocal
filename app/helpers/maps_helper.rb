module MapsHelper
  def display_options
    options_for_select(Chart.all.map do |chart|
      [I18n.t("charts.#{ chart.key }"), chart.key]
    end)
  end
end
