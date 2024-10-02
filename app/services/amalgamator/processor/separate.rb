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
              result = dataset_b_value - dataset_a_value
              result < 0 ? 0 : result
            else
              raise ArgumentError, "Unknown combination method '#{item.nested_combination_method}' for InterfaceItem: #{item.key}"
            end

          [item.key, value_c]
        end.compact
      end

      # Helper method to fetch and validate values from datasets
      def fetch_valid_value(dataset, item)
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
        if dataset_b_value ==0 and dataset_a_value ==0
          return 0
        end

        # Fetch weights for both datasets
        weight_a = weight_keys.sum(1) { |key| fetch_weight(subtracted_dataset, key, item) }
        weight_b = weight_keys.sum(1) { |key| fetch_weight(target_dataset, key, item) }


        # Ensure weights are numeric and handle potential zero division - if weights are equal, revert to average
        if weight_a == weight_b
          log_error(item, "Same weights - Reverting to average")
          return calculate_average(dataset_b_value, dataset_a_value)
        end

        denominator = weight_b - weight_a

        if denominator.zero?
          log_error(item, "Division by zero encountered - Reverting to average")
          return calculate_average(dataset_b_value, dataset_a_value)
        end

        # Perform the reverse weighted average calculation
        numerator = (dataset_b_value * weight_b) - (dataset_a_value * weight_a)
        value_c = numerator / denominator

        value_c
      end

      # Helper method to fetch weights from datasets
      def fetch_weight(dataset, weight_key, item)
        if weight_key.is_a?(Hash)
          value = aggregate_weighing_function(weight_key, dataset, item)
        else
          attribute = dataset.editable_attributes.find(weight_key.to_s)
          return 0 if attribute.nil?
          value = attribute.value
        end
        # Convert the value to float
        weight = value.to_f
        weight > 0 ? weight : 0
      end

      def aggregate_weighing_function(fn_hash, dataset, item)
        function = fn_hash.keys.first
        attributes = fn_hash.values.first

        if function == 'sum'
          sum = attributes.sum do |a|
            attr = dataset.editable_attributes.find(a.to_s)
            attr ? attr.value.to_f : 0.0
          end
          sum
        else
          log_error(item, "Unsupported function '#{function}' used in aggregation. Only 'sum' is allowed.")
          nil
        end
      end
    end
  end
end
