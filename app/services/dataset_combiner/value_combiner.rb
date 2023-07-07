# frozen_string_literal: true

class DatasetCombiner

  # The ValueCombiner combines the values for each unique InterfaceItem found
  # in all given datasets. The manner in which these values are combined
  # is determined by the 'combination_method' property in each item.
  #
  # The ValueCombiner returns a hash with the item keys as keys and
  # the items combined value as values.
  class ValueCombiner

    def perform(datasets)
      combined_item_values = {}

      InterfaceElement.items.each do |item|
        plucked_item_values = @datasets.pluck(item.key.to_sym)

        # Skip this item unless data for it is present in any of the given datasets
        next if plucked_item_values.blank?

        case item.combination_method
        when 'sum'
          combined_item_values[item.key] = plucked_item_values.sum
        when 'average'
          combined_item_values[item.key] = (plucked_item_values.sum.to_f / plucked_item_values.length)
        when 'min'
          combined_item_values[item.key] = plucked_item_values.min
        when 'max'
          combined_item_values[item.key] = plucked_item_values.max
        when Hash # When combination_method is a hash this means it is the weighted average
          combined_item_values[item.key] = calculate_weighted_average(item, plucked_item_values)
        else
          raise StandardError, "Combination method for item '#{item.key}' is unknown: #{item.combination_method}. Aborting!"
        end
      end

      # We loop through the items twice to make sure all of their combined values
      # are present in @combined_item_values so they can be matched with share groups
      # in the next loop.
      InterfaceElement.items.each do |item|
        next unless item.flexible

        total = 0.0

        item.share_group.each { |group| total += combined_item_values[group] }

        combined_item_values[item.key] = (1 - total)
      end

      combined_item_values.map! { |value| value.round(6) }
    end

    private

    def calculate_weighted_average(item, plucked_item_values)
      weighing_keys = item.combination_method['weighted_average']

      weighted_averages = @datasets.map do |dataset|
        weight = 1.0

        [
          dataset[item.key],
          weighing_keys.map { |weighing_key| weight *= dataset[weighing_key] }
        ]
      end

      # If the value of all weighted averages is 0 we return the 'normal' average.
      # See: https://github.com/quintel/etlocal/issues/464
      if weighted_averages.all? { |wa| wa[0].zero? }
        return (plucked_item_values.sum.to_f / plucked_item_values.length)
      end

      numerator = weighted_averages.sum { |wa| wa[0] * wa[1] }
      denominator = weighted_averages.sum(&:last)

      begin
        numerator / denominator
      rescue ZeroDivisionError
        (plucked_item_values.sum.to_f / plucked_item_values.length)
      end
    end

  end

end
