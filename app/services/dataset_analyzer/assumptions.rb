module DatasetAnalyzer
  module Assumptions
    ASSUMPTIONS = YAML.load_file(Rails.configuration.assumptions_path).freeze

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
      value = ASSUMPTIONS[:efficiencies].fetch(key)

      value.is_a?(Numeric) ? value : efficiency_from_node(key, value)
    end

    def conversion(key)
      ASSUMPTIONS[:conversions].fetch(key)
    end

    private

    def efficiency_from_node(key, value)
      node = Atlas::Node.find(key)

      if value.is_a?(Symbol)
        node.output.fetch(value)
      elsif value.is_a?(Hash)
        (1 / node.input.fetch(value.fetch(:input)))
      end
    end
  end
end
