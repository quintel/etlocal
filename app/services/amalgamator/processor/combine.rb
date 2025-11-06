# frozen_string_literal: true

module Amalgamator
  # The ValueProcessor is the core worker of the DatasetCombiner classes.
  # It combines the values for each unique InterfaceItem found in the given datasets.
  # The manner in which these values are combined is determined by the
  # 'combination_method' attribute set in each InterfaceItem. This defaults to 'sum'.
  #
  # The ValueProcessor returns a hash with the item keys as keys and
  # the items' combined value as values.
  class Processor::Combine < Processor::Base
    class << self
      # The values for the given datasets are processed in 3 steps:
      # 1. Combine the values according to the combination_method of set in the InterfaceItem
      # 2. Round all combined values to 8 decimals
      # 3. If flexible is true for an InterfaceItem, make it fill out the share of the group it belongs to
      def perform(datasets)
        combined_item_values = combine_item_values(datasets)
        adjust_flexible_shares(combined_item_values)
        round_item_values(combined_item_values)
      end


      # Creates a hash with the item's keys as keys and the combined values of all datasets as values, e.g.:
      # {
      #   number_of_cars: 5,
      #   co2_emission_1990: 1000,
      #   interconnector_capacity: 100
      # }
      # The method uses the combination method set in the InterfaceItem to determine how values should be combined.
      def combine_item_values(datasets)
        InterfaceElement.items.to_h do |item|
          plucked_item_values = pluck_item_values(item, datasets)

          # Skip items where all values are zero
          next [item.key, 0] if all_values_zero?(plucked_item_values)

          # Combine values based on the item's combination method
          combined_value = combine_values(item, plucked_item_values, datasets)

          [item.key, combined_value]
        end.compact
      end

      private

      # Fetch and validate the values from the datasets
      def pluck_item_values(item, datasets)
        datasets.filter_map do |set|
          attribute = set.editable_attributes.find(item.key.to_s)

          unless attribute
            log_error(item, "Dataset with geo-id '#{set.geo_id}' is missing the attribute '#{item.key}'")
            next nil
          end

          if item.unit == 'string'
            value = attribute.value
            next nil if value.blank?

            value
          else
            value = coerce_numeric(attribute.value)

            unless item.flexible || value.is_a?(Numeric)
              log_error(item, "Dataset with geo-id '#{set.geo_id}' contains a non-numeric value (#{attribute.value})")
              next nil
            end

            value
          end
        end
      end

      # Check if all values in the array are zero
      def all_values_zero?(values)
        values.all?(0)
      end

      # Combine the values based on the combination method of the item
      def combine_values(item, values, datasets)
        if item.unit == 'string'
          return values.find { |value| value.present? }
        end

        case item.nested_combination_method
        when 'average'
          avg(values)
        when 'min', 'max'
          values.send(item.nested_combination_method)
        when ->(cm) { cm.is_a?(Hash) && cm.key?('weighted_average') }
          calculate_weighted_average(item, datasets, values)
        when 'sum', '', nil # Default to 'sum'
          values.sum
        else
          argument_error("Unknown combination_method '#{item.nested_combination_method}' for interface item: #{item.key}")
        end
      end

      def avg(values)
        values.sum.to_f / values.length
      end

      def calculate_weighted_average(item, datasets, plucked_item_values)
        weighing_keys = item.nested_combination_method['weighted_average']

        if weighing_keys.blank?
          argument_error(
            "No weighing keys defined for combination method 'weighted_average' in interface item: #{item.key}"
          )
        end

        weighted_values = datasets.map do |dataset|
          weight = 1.0
          weighing_keys.each do |key|
            value = \
              if key.is_a?(Hash)
                aggregate_weighing_function(key, dataset, item)
              else
                dataset.editable_attributes.find(key.to_s).try(:value)
              end

            next if value.blank? || value.zero?

            weight *= value
          end

          [dataset.editable_attributes.find(item.key.to_s).value, weight]
        end

        # If the value of all weighted averages is 0 we return the 'normal' average.
        return avg(plucked_item_values) if weighted_values.all? { |wa| wa[0].zero? }

        numerator = weighted_values.sum { |wa| wa[0] * wa[1] }
        denominator = weighted_values.sum(&:last)

        begin
          numerator / denominator
        rescue ZeroDivisionError
          avg(plucked_item_values)
        end
      end

      def aggregate_weighing_function(fn_hash, dataset, item)
        function = fn_hash.keys.first
        attributes = fn_hash.values.first

        if function == 'sum'
          attributes.sum do |a|
            attribute = dataset.editable_attributes.find(a.to_s)

            if attribute.nil?
              log_error(item, "Dataset with geo-id '#{dataset.geo_id}' is missing weighting attribute '#{a}'")
              next 0.0
            end

            value = coerce_numeric(attribute.value)

            unless value.is_a?(Numeric)
              log_error(item, "Dataset with geo-id '#{dataset.geo_id}' contains a non-numeric weighting value (#{attribute.value}) for '#{a}'")
              next 0.0
            end

            value
          end
        else
          log_error(item, "Unsupported function '#{function}' used in aggregation. Only 'sum' is allowed.")
          nil
        end
      end

      def coerce_numeric(value)
        case value
        when true then 1.0
        when false then 0.0
        else
          value
        end
      end
    end
  end
end
