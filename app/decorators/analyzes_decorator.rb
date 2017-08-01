class AnalyzesDecorator
  def self.decorate(analyzes)
    new(analyzes)
  end

  def initialize(analyzes)
    @analyzes = analyzes
  end

  def initializer_inputs
    init = @analyzes.fetch(:init)

    Input
      .find_all(init.keys)
      .group_by(&:group)
      .each_with_object({}) do |(group, inputs), object|
        object[group] = Hash[inputs.map do |input|
          [input.key, init[input.key]]
        end]
      end
  end

  def area_attributes
    @analyzes.except(:init)
  end
end
