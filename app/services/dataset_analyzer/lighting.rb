class DatasetAnalyzer
  class Lighting < Base
    def analyze
      to_shares.merge(households_useful_demand_lighting: total_useful_demand)
    end

    def all_useful_demands
      @all_useful_demands ||=
        ratio(:lighting).each_with_object({}) do |(key, lighting_ratio), object|
          object[key] = total_demand * lighting_ratio * efficiency_for(key)
        end
    end

    private

    def total_demand
      @analyzed_attributes.fetch(:lighting)
    end
  end
end
