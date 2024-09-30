# frozen_string_literal: true

module Amalgamator
  # Subtracts a dataset from the target dataset to create a new dataset
  class Processor::Separate < Processor::Base
    class << self
      # The values for the given datasets are processed in 3 steps:
      # 1. Subtract the values according to the combination_method set in the InterfaceItem
      # 2. Round all 'subtracted' values to 8 decimals
      # 3. Adjust flexible shares if necessary
      def perform(target_dataset, subtracted_dataset)
        dataset_c_values = calculate_item_values(target_dataset, subtracted_dataset) # dataset C is the result of subtracting A from B
        round_item_values(dataset_c_values)
        dataset_c_values = adjust_flexible_shares(dataset_c_values)

        dataset_c_values
      end

      # Creates a hash with the item's keys as keys and the values for dataset C as values, e.g.:
      # {
      #   number_of_cars: 3,          # C = B - A
      #   co2_emission_1990: 500,     # C = B - A
      #   interconnector_capacity: 50 # C = B - A
      # }
      def calculate_item_values(target_dataset, subtracted_dataset)
        InterfaceElement.items.to_h do |item|
          dataset_b_value = fetch_valid_value(target_dataset, item)
          dataset_a_value = fetch_valid_value(subtracted_dataset, item)

          # Use the combination method to determine how C is calculated from B and A
          value_c = case item.nested_combination_method
            when 'average'
              calculate_average(dataset_b_value, dataset_a_value)
            when 'min', 'max' # Just take the value of B in these cases
              dataset_b_value
            when ->(cm) { cm.is_a?(Hash) && cm.key?('weighted_average') }
              calculate_weighted_average(item, target_dataset, subtracted_dataset, dataset_b_value, dataset_a_value)
            when 'sum', '', nil # Default to 'difference' (C = B - A)
              dataset_b_value - dataset_a_value
            else
              raise ArgumentError, "Unknown combination method '#{item.nested_combination_method}' for InterfaceItem: #{item.key}"
            end

          [item.key, value_c]
        end.compact
      end

      # Helper method to fetch and validate values from datasets
      def fetch_valid_value(dataset, item)
        if dataset.nil?
          log_error(item, "Dataset is missing for item #{item.key}")

        end

        value = dataset.editable_attributes.find(item.key.to_s).value
        if value.nil?
          log_error(item, "Value not found for item #{item.key} in dataset #{dataset.geo_id}")
          value = 0
        end

        # All non-flexible item values should be numeric
        unless item.flexible || value.is_a?(Numeric)
          log_error(item, "Dataset with geo-id '#{dataset.geo_id}' contains a non-numeric value (#{value}) for InterfaceItem: #{item.key}")
          value =0
        end

        value
      end

      private

      # For average values, assume two datasets and reverse by splitting the difference
      # E.g. A = 10, B = 12, B-A = 2, C = B + (B-A) = 14
      # This is a simplification that assumes that if the value you are subtracting is
      # lower than the average, the new value will be higher than the average and vice versa.
      def calculate_average(value_b, value_a)
        return value_b + value_b - value_a
      end

      def calculate_weighted_average(item, target_dataset, subtracted_dataset, dataset_b_value, dataset_a_value)
        # Extract the weight keys from the nested_combination_method
        weight_keys = item.nested_combination_method['weighted_average']

        weight_a = weight_keys.sum(0) { |key| fetch_weight(subtracted_dataset, key) }
        weight_b = weight_keys.sum(0) { |key| fetch_weight(target_dataset, key) }

        # Ensure weights are numeric and handle potential zero division
        denominator = weight_b - weight_a
        if denominator.zero?
          log_error(item, "Division by zero encountered for item #{item.key}. Setting numerator value to 0.")
          return 0
        end

        # Perform the reverse weighted average calculation
        numerator = (dataset_b_value * weight_b) - (dataset_a_value * weight_a)
        denominator = weight_b - weight_a
        value_c = numerator / denominator

        value_c
      end

      # Helper method to fetch weights from datasets
      def fetch_weight(dataset, weight_key)
        attribute = dataset.editable_attributes.find(weight_key.to_s)

        # If the attribute is nil, return a default value of 0
        return 0 if attribute.nil?

        # Convert the value to float and ensure it's not nil
        weight = attribute.value.to_f

        # If the weight value is invalid (e.g., zero or negative), return a default value of 0
        weight > 0 ? weight : 0
      end
    end
  end
end
