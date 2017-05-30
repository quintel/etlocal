module DatasetAnalyzer
  class Industry
    class Nulled < Base
      def analyze
        return {} if has_industry

        industry_initializer_inputs.each_with_object({}) do |key, object|
          object[key] = 0
        end
      end

      private

      # Internal: industry_initializer_inputs
      #
      # Fetches all the initializer inputs which are able to 0 all the demand
      # of the industry sector.
      def industry_initializer_inputs
        Etsource.inputs.map(&:key).select do |key|
          key =~ /(^industry_useful_demand_|_production$)/
        end
      end
    end
  end
end
