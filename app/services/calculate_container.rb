class CalculateContainer
  def initialize(dataset, calculation_params)
    unless dataset.is_a?(Dataset)
      raise ArgumentError, "dataset should be of 'Dataset' type"
    end

    unless Transformer::DatasetCast.new(calculation_params).valid?
      raise ArgumentError, "mandatory arguments can't be blank"
    end

    @dataset            = dataset
    @calculation_params = calculation_params
  end

  def tryout!
    begin
      Dataset::Scaler.scale!(@dataset, @calculation_params)
      Dataset::Analyzer.analyze!(@dataset, @calculation_params)

      atlas_dataset = Atlas::Dataset::Derived.find(@dataset.temp_name)

      Atlas::Runner.new(atlas_dataset).calculate
    ensure
      prune_dataset!
    end
  end

  private

  def prune_dataset!
    begin
      atlas_dataset = Atlas::Dataset::Derived.find(@dataset.temp_name)
      FileUtils.rm_rf(atlas_dataset.dataset_dir)
    rescue Atlas::DocumentNotFoundError => e
    end
  end
end
