class AnalyzesDecorator
  def self.decorate(analyzes)
    new(analyzes)
  end

  def initialize(analyzes)
    @analyzes = analyzes
  end

  def graph_values
    @analyzes.fetch(:graph_values)
  end

  def area_attributes
    @analyzes.fetch(:area)
  end
end
