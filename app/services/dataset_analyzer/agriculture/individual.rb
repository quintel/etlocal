module DatasetAnalyzer
  class Agriculture
    class Individual < Base
      def analyze
        return {} unless has_agriculture

        @dataset_edits.slice(*valid_input_keys)
      end

      private

      def valid_input_keys
        Etsource.inputs.map(&:key).select do |key|
          key =~ /agriculture/
        end
      end
    end
  end
end
