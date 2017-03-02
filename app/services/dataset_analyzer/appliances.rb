class DatasetAnalyzer
  class Appliances < Base
    # Appliances division
    def analyze
      ratio(:appliances).transform_values do |appliances_ratio|
        total_demand * appliances_ratio
      end
    end

    private

    def total_demand
      @analyzed_attributes.fetch(:appliances)
    end
  end
end
