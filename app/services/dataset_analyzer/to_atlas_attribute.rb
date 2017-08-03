module DatasetAnalyzer
  class ToAtlasAttribute < Base
    def analyze
      static.merge(area_attributes).merge(init: initializer_inputs)
    end

    private

    def initializer_inputs
      Atlas::InitializerInput.all.each_with_object({}) do |input, object|
        if value = @analyzed_attributes[input.key]
          object[input.key] = value
        end
      end
    end

    def static
      {
        number_of_cars: number_of_cars,
        number_of_residences: number_of_residences,
        number_of_inhabitants: number_of_inhabitants,
        number_of_old_residences: number_of_old_residences,
        number_of_new_residences: number_of_new_residences,
        has_industry: @dataset_edits.fetch(:has_industry),
        has_agriculture: @dataset_edits.fetch(:has_agriculture)
      }
    end

    def area_attributes
      @analyzed_attributes.slice(*Atlas::Dataset.attribute_set.map(&:name))
    end
  end
end
