module DatasetAnalyzer
  class Industry
    class Individual < Base
      def analyze
        return {} unless has_industry

        @dataset_edits.slice(*valid_input_keys)
      end

      private

      def valid_input_keys
        Etsource.inputs.map(&:key).select do |key|
          key =~ /industry/
        end
      end
    end
  end
end
