class DatasetAnalyzer
  class RoofSurfaceAvailableForPV < Base
    def analyze
      {
        residences_roof_surface_available_for_pv:
          residences_roof_surface_available_for_pv,
        buildings_roof_surface_available_for_pv:
          0,
        households_solar_pv_solar_radiation_market_penetration:
          households_solar_pv_solar_radiation_market_penetration
      }
    end

    private

    def households_solar_pv_solar_radiation_market_penetration
      (number_of_residences_with_solar_pv / number_of_residences) * 100
    end

    def residences_roof_surface_available_for_pv
      (roof_surface_available_for_pv / 1e6) * number_of_residences
    end
  end
end
