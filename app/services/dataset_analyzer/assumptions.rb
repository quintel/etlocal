class DatasetAnalyzer
  module Assumptions
    ASSUMPTIONS = YAML.load_file(Rails.root.join("config", "assumptions.yml")).freeze

    def ratio(key)
      ASSUMPTIONS[:ratios].fetch(key)
    end

    def conversion(key)
      ASSUMPTIONS[:conversions].fetch(key)
    end

    def demand(key)
      ASSUMPTIONS[:demands].fetch(key)
    end

    def efficiency_for(key)
      ASSUMPTIONS[:efficiencies].fetch(key)
    end

    def conversion(key)
      ASSUMPTIONS[:conversions].fetch(key)
    end
  end
end
