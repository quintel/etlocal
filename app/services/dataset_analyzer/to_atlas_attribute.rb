class DatasetAnalyzer
  class ToAtlasAttribute < Base
    STATIC = %w(
      number_of_cars
      number_of_residences
      number_of_inhabitants
    )

    AREA_ATTRIBUTES = %i(
      residences_roof_surface_available_for_pv
      buildings_roof_surface_available_for_pv
      has_agriculture
      has_buildings
      has_industry
      has_other
      number_of_buildings
    )

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
      @dataset_edits.slice(*STATIC).symbolize_keys
    end

    def area_attributes
      @analyzed_attributes.slice(*AREA_ATTRIBUTES)
    end
  end
end
