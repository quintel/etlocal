class DatasetAnalyzer
  module Shares
    def to_shares
      all_useful_demands.each_with_object({}) do |(key, value), object|
        object["#{ key }_share".to_sym] = (value / total_useful_demand) * 100
      end
    end

    def total_useful_demand
      all_useful_demands.values.sum
    end
  end
end
