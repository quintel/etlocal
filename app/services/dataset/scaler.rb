class Dataset
  module Scaler
    module_function

    def scale!(dataset, attributes)
      Atlas::Scaler.new(
        dataset.country,
        dataset.temp_name,
        attributes.fetch('number_of_residences')
      ).create_scaled_dataset
    end
  end
end
