module DatasetAnalyzer
  class EnergySector < Base
    def analyze
      ASSUMPTIONS[:number_of].transform_values do |value|
        value * number_of_residences
      end
    end
  end
end
