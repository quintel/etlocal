module DatasetAnalyzer
  class Transport < Base
    def analyze
      { transport_useful_demand_car_kms: transport_useful_demand_car_kms }
    end

    def transport_useful_demand_car_kms
      demand(:transport).fetch(:transport_car_demand) * number_of_cars
    end
  end
end
