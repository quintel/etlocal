module DatasetAnalyzer
  class Base
    include DatasetAnalyzer::Assumptions
    include DatasetAnalyzer::Shares

    def self.analyze(dataset, dataset_edits, analyzed_attributes)
      new(dataset, dataset_edits, analyzed_attributes).analyze
    end

    # Initializing an analyzer
    #
    # Arguments:
    # - dataset             = Atlas::Dataset
    # - dataset_edits       = Hash[key, val]
    # - analyzed_attributes = Hash[key, val]
    #
    def initialize(dataset, dataset_edits, analyzed_attributes)
      @dataset             = dataset
      @dataset_edits       = defaults.merge(dataset_edits)
      @analyzed_attributes = analyzed_attributes

      @dataset_edits.each_pair do |key, value|
        define_singleton_method(key) { value }
      end

      unless @dataset.is_a?(Atlas::Dataset)
        raise ArgumentError, 'dataset argument is not an Atlas dataset'
      end
    end

    def analyze
      raise NotImplentedError, "base class '#{ self.class }' misses analyze method"
    end

    private

    def defaults
      { 'has_industry' => false, 'has_agriculture' => false }
    end

    def ratio_houses
      {
        old: number_of_old_residences / number_of_residences,
        new: number_of_new_residences / number_of_residences
      }
    end

    def total_demand_electricity
      @total_demand_electricity ||=
        electricity_consumption * conversion(:kwh_to_mj) * number_of_residences
    end

    def total_demand_gas
      @total_demand_gas ||=
        gas_consumption * conversion(:m3_to_mj) * number_of_residences
    end

    def number_of_old_residences
      @number_of_old_residences ||=
        (number_of_residences * (percentage_of_old_residences / 100))
    end

    def number_of_new_residences
      @number_of_new_residences ||=
        (number_of_residences - number_of_old_residences)
    end

    def graph
      @graph ||= Atlas::Runner.new(@dataset).calculate
    end
  end
end
