class DatasetAnalyzer
  class Base
    include DatasetAnalyzer::Assumptions
    include DatasetAnalyzer::Shares

    def self.analyze(dataset_edits, analyzed_attributes)
      new(dataset_edits, analyzed_attributes).analyze
    end

    def initialize(dataset_edits, analyzed_attributes)
      @dataset_edits       = dataset_edits
      @analyzed_attributes = analyzed_attributes

      @dataset_edits.each_pair do |key, value|
        define_singleton_method(key) { value }
      end
    end

    def analyze
      raise NotImplentedError, "base class '#{ self.class }' misses analyze method"
    end

    def total_demand_electricity
      @total_demand_electricity ||=
        electricity_consumption * conversion(:kwh_to_mj) * number_of_residences
    end

    def total_demand_gas
      @total_demand_gas ||=
        gas_consumption * conversion(:m3_to_mj) * number_of_residences
    end
  end
end
