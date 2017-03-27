module MapsHelper
  def layer_options
    options_for_select(LAYERS['chart'].map do |layer|
      [layer['name'], layer['name'] + '-visual']
    end)
  end

  def display_options
    []
  end
end
