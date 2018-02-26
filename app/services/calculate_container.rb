class CalculateContainer
  def initialize(calculation_params)
    @calculation_params = calculation_params
  end

  def tryout!
    Transformer::DatasetGenerator.new(@calculation_params).generate(
      [ Transformer::DatasetGenerator::Validator,
        Transformer::DatasetGenerator::Destroyer ]
    )
  end
end
