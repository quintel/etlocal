# frozen_string_literal: true

class DatasetCombiner

  # The ValueProcessor is the core worker of the DatasetCombiner classes.
  # It combines the values for each unique InterfaceItem found in the given datasets.
  # The manner in which these values are combined is determined by the
  # 'combination_method' attribute set in each InterfaceItem. This defaults to 'sum'.
  #
  # The ValueProcessor returns a hash with the item keys as keys and
  # the items' combined value as values.
  class ValueProcessor

    class << self

      # The values for the given datasets are processed in 3 steps:
      # 1. Combine the values according to the combination_method of set in the InterfaceItem
      # 2. Round all combined values to 8 decimals
      # 3. If flexible is true for an InterfaceItem, make it fill out the share of the group it belongs to
      def perform(datasets)
        combined_item_values = combine_item_values(datasets)
        combined_item_values.transform_values! { |value| value.present? ? value.round(8) : 0.0 }
        combined_item_values = calculate_flexible_shares(combined_item_values)

        combined_item_values
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
          plucked_item_values = datasets.filter_map do |set|
            value = set.editable_attributes.find(item.key.to_s).value

            # All non-flexible item values should be numbers. Nil or String values are not allowed.
            if !item.flexible && !value.is_a?(Numeric)
              puts <<~MSG
                💩 Dataset with geo-id '#{set.geo_id}' contains a non-numeric value (#{value}) for interface item:
                #{item.key}
                (parent element: #{item.try(:group).try(:element).try(:key)}, parent group: #{item.try(:group).try(:header)})
              MSG
            end

            value
          end

          next [item.key, 0] if plucked_item_values.all?(0)

          # We use the nested_combination_method. This will return the group combination_method
          # if a combination_method is not set in the InterfaceItem itself.
          combined_value =
            case item.nested_combination_method
            when 'average'
              avg(plucked_item_values)
            when 'min'
              plucked_item_values.min
            when 'max'
              plucked_item_values.max
            when Hash # When combination_method is a hash this means it is the weighted average
              calculate_weighted_average(item, datasets, plucked_item_values)
            when 'sum', '', nil # Default to 'sum'
              plucked_item_values.sum
            else # combination_method is set to an unknown value
              argument_error(
                <<~MSG
                  Don't know how to deal with combination_method '#{item.nested_combination_method}' in interface item:
                  #{item.key}
                  (parent element: #{item.try(:group).try(:element).try(:key)}, parent group: #{item.try(:group).try(:header)})
                MSG
              )
            end

          [item.key, combined_value]
        end.compact
      end

      # Goes through the combined values created above and then determines if flexible items exist
      # that need to fill up the share left in the group it belongs to, to 100% (represented as '1' here)
      def calculate_flexible_shares(combined_item_values)
        InterfaceElement.items.to_h do |item|
          # Only attempt to calculate the flexible value for this item
          # if it is 'flexible' and the item is part of a group of multiple items
          unless item.flexible && item.group.try(:present?) && item.group.items.length > 1
            next [item.key, combined_item_values[item.key]]
          end

          # Raise an error if more than one items in the group are defined as 'flexible'
          if item.group.items.sum { |group_item| group_item.flexible ? 1 : 0 } > 1
            argument_error(
              <<~MSG
                More than one flexible InterfaceItems found in InterfaceGroup #{item.try(:group).try(:header)}
                (parent element: #{item.try(:group).try(:element).try(:key)}
              MSG
            )
          end

          group_total = 0.0

          item
            .group
            .items
            .reject { |group_item| group_item.key == item.key }
            .each { |group_item| group_total += combined_item_values[group_item.key] }

          if group_total > 1.0
            puts <<~MSG
              💩 The summed value of group shares was more than 1.0 (#{group_total}) before attempting to calculate flexible share:
              #{item.key}
              (parent element: #{item.try(:group).try(:element).try(:key)}, parent group: #{item.try(:group).try(:header)})
              Skipping flexible share calculation for this interface item!
            MSG

            next [item.key, combined_item_values[item.key]]
          end

          group_total_including_flexible = group_total + (1 - group_total)

          if group_total_including_flexible > 1.0
            puts <<~MSG
              💩 The group total was more than 1.0 (#{group_total_including_flexible}) after calculating flexible share:
              #{item.key}
              (parent element: #{item.try(:group).try(:element).try(:key)}, parent group: #{item.try(:group).try(:header)})
              Skipping flexible share calculation for this interface item!
            MSG

            next [item.key, combined_item_values[item.key]]
          end

          [item.key, (1 - group_total)]
        end
      end

      private

      def avg(values)
        values.sum.to_f / values.length
      end

      def calculate_weighted_average(item, datasets, plucked_item_values)
        weighing_keys = item.nested_combination_method['weighted_average']

        if weighing_keys.blank?
          argument_error(
            <<~MSG
              No weighing keys defined for combination method 'weighted average' in interface item:
              #{item.key}
              (parent element: #{item.try(:group).try(:element).try(:key)}, parent group: #{item.try(:group).try(:header)})
              Aborting.
            MSG
          )
        end

        weighted_averages = datasets.map do |dataset|
          weight = 1.0
          weighing_keys.each do |key|
            value = dataset.editable_attributes.find(key.to_s).value
            weight *= value unless value.zero?
          end

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

      def argument_error(msg)
        raise ArgumentError, "#{msg}. Aborting."
      end

    end

  end

end
