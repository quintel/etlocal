# frozen_string_literal: true

class DatasetCombiner

  # The ValueProcessor is the core worker of the DatasetCombiner classes.
  # It combines the values for each unique InterfaceItem found
  # in the given datasets. The manner in which these values are combined
  # is determined by the 'combination_method' property in each item.
  #
  # The ValueProcessor returns a hash with the item keys as keys and
  # the items' combined value as values.
  class ValueProcessor

    class << self

      def perform(datasets)
        combined_item_values = combine_item_values(datasets)

        combined_item_values = calculate_flexible_values(combined_item_values)

        combined_item_values.transform_values! { |value| value.round(6) }
      end

      def combine_item_values(datasets)
        combined_item_values = {}

        InterfaceElement.items.map do |item|
          plucked_item_values = datasets.map { |set| set.editable_attributes.find(item.key.to_s).value }

          # Skip this item unless data for it is present in any of the given datasets
          next if plucked_item_values.blank?

          case item.combination_method
          when 'average'
            combined_item_values[item.key] = avg(plucked_item_values)
          when 'min'
            combined_item_values[item.key] = plucked_item_values.min
          when 'max'
            combined_item_values[item.key] = plucked_item_values.max
          when Hash # When combination_method is a hash this means it is the weighted average
            combined_item_values[item.key] = calculate_weighted_average(item, datasets, plucked_item_values)
          else # Default to 'sum'
            combined_item_values[item.key] = plucked_item_values.sum
          end
        end

        combined_item_values
      end

      def calculate_flexible_values(combined_item_values)
        InterfaceElement.items.each do |item|
          next unless item.flexible

          total = 0.0

          item.share_group.each { |group| total += combined_item_values[group] }

          combined_item_values[item.key] = (1 - total)
        end

        combined_item_values
      end

      private

      def avg(values)
        values.sum.to_f / values.length
      end

      def calculate_weighted_average(item, datasets, plucked_item_values)
        weighing_keys = item.combination_method[:weighted_average]

        if weighing_keys.blank?
          raise(
            ArgumentError, <<~MSG
              "Error! No weighing keys defined for combination method 'weighted average' in item #{item.key}
              (parent element: #{item.try(:group).try(:element).try(:key)}, parent group: #{item.try(:group).try(:header)})"
            MSG
          )
        end

        weighted_averages = datasets.map do |dataset|
          weight = 1.0
          weighing_keys.each { |key| weight *= dataset.editable_attributes.find(key.to_s).value }

          [dataset.editable_attributes.find(item.key.to_s).value, weight]
        end

        # If the value of all weighted averages is 0 we return the 'normal' average.
        # See: https://github.com/quintel/etlocal/issues/464
        if weighted_averages.all? { |wa| wa[0].zero? }
          return avg(plucked_item_values)
        end

        numerator = weighted_averages.sum { |wa| wa[0] * wa[1] }
        denominator = weighted_averages.sum(&:last)

        begin
          numerator / denominator
        rescue ZeroDivisionError
          avg(plucked_item_values)
        end
      end

    end

  end

end
