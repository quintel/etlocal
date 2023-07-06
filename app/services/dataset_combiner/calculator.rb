class DatasetCombiner

  class Calculator

    def perform(datasets)
      @combined_item_values = {}

      calculate_combined_values(datasets)
      calculate_flexible_shares(datasets)

      @combined_item_values.map! { |value| value.round(6) }
    end

    private

    def calculate_weighted_average(item, combined_data)
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
        return (combined_data.sum.to._f / combined_data.length)
      end

      numerator = weighted_averages.sum { |wa| wa[0] * wa[1] }
      denominator = weighted_averages.sum(&:last)

      begin
        numerator / denominator
      rescue ZeroDivisionError
        (combined_data.sum.to._f / combined_data.length)
      end
    end

    def calculate_combined_values
      InterfaceElement.items.each do |item|
        # Skip this item unless data for it is present in any of the given datasets
        combined_data = @datasets.pluck(item.key.to_sym)

        next if combined_data.blank?

        case item.combination_method
        when 'sum'
          @combined_item_values[item.key] = combined_data.sum
        when 'average'
          @combined_item_values[item.key] = (combined_data.sum.to._f / combined_data.length)
        when 'min'
          @combined_item_values[item.key] = combined_data.min
        when 'max'
          @combined_item_values[item.key] = combined_data.max
        when Hash # This is always the weighted average
          @combined_item_values[item.key] = calculate_weighted_average(item, combined_data)
        else
          raise StandardError, "Combination method for item '#{item.key}' is unknown: #{item.combination_method}"
        end

      end
    end

    def calculate_flexible_shares
      InterfaceElement.items.each do |item|
        next unless item.flexible

        total = 0.0

        item.share_group.each { |group| total += @combined_item_values[group] }

        @combined_item_values[item.key] = (1 - total)
      end
    end

  end

end
