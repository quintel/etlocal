module DatasetAnalyzer
  class Agriculture
    class Nulled < Base
      def analyze
        return {} if has_agriculture

        agriculture_initializer_inputs.each_with_object({}) do |key, object|
          object[key] = 0
        end
      end

      private

      # Internal: agriculture_initializer_inputs
      #
      # Fetches all the initializer inputs which are able to 0 all the demand
      # of the agriculture sector.
      def agriculture_initializer_inputs
        Etsource.inputs.map(&:key).select do |key|
          key =~ /(^agriculture_useful_demand_)/
        end
      end
    end
  end
end
