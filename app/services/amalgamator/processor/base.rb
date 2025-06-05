# frozen_string_literal: true

module Amalgamator
  class Processor::Base
    class << self
      def perform(datasets); end

      private

      def argument_error(msg)
        raise ArgumentError, "#{msg}. Aborting."
      end

      def log_error(item, message)
        puts <<~MSG
          Error for InterfaceItem '#{item.key}':
          #{message}
          (Parent element: #{item.try(:group).try(:element).try(:key)}, Parent group: #{item.try(:group).try(:header)})
        MSG
      end

      # Adjusts the flexible shares in the group if applicable
      def adjust_flexible_shares(dataset_c_values)
        InterfaceElement.items.to_h do |item|
          unless item.flexible && item.group.try(:present?) && item.group.items.length > 1
            next [item.key, dataset_c_values[item.key]]
          end

          # Check for multiple flexible shares in the group
          flexible_items = item.group.items.select(&:flexible)
          if flexible_items.length > 1
            log_error(item, "Multiple flexible shares found in group '#{item.group.try(:header)}'.")
            next [item.key, dataset_c_values[item.key]]
          end

          group_total = item.group.items.reject { |group_item| group_item.key == item.key }
                                .sum { |group_item| dataset_c_values[group_item.key] }

          if group_total > 1.0
            puts "The summed value of group shares exceeded 1.0 for item: #{item.key}. Skipping flexible share adjustment."
            next [item.key, dataset_c_values[item.key]]
          end

          [item.key, (1 - group_total)]
        end
      end

      # Rounds down each dataset value to `precision` decimals (default 8),
      # replacing nil with 0.0, and ensures that the sum of all rounded values
      # matches the floored total of the original values. Any leftover units
      # from flooring are distributed to the items with the largest fractional parts.
      def round_item_values(item_values, precision: 8)
        keys       = item_values.keys
        raw_values = keys.map { |k| item_values[k].present? ? item_values[k] : 0.0 }
        rounded_array = smart_floor(raw_values, precision: precision)
        keys.each_with_index do |k, idx|
          item_values[k] = rounded_array[idx]
        end
        item_values
      end

      # Floors each value in `shares` to `precision` decimals while preserving
      # the overall floored sum.
      def smart_floor(shares, precision: 8)
        multiplier      = 10**precision
        target_total    = (shares.sum * multiplier).floor
        scaled_values   = shares.map { |s| s * multiplier }
        floored_scaled  = scaled_values.map(&:floor)
        remainder       = target_total - floored_scaled.sum
        ranked_indices  = rank_by_fractional(scaled_values, floored_scaled)

        if remainder.positive?
          distribute_remainder!(floored_scaled, ranked_indices, remainder)
        end

        unscale_values(floored_scaled, multiplier)
      end

      # Rank indices by their fractional parts descending.
      # Returns an array of indices sorted so that largest fractional parts come first.
      def rank_by_fractional(scaled_values, floored_scaled)
        scaled_values
          .each_with_index
          .map { |scaled_val, i| [scaled_val - floored_scaled[i], i] }
          .sort_by { |fraction, i| -fraction }
          .map { |_, i| i }
      end

      # Distribute `remainder` integer units across floored_scaled by incrementing
      # the elements at the top of ranked_indices.
      def distribute_remainder!(floored_scaled, ranked_indices, remainder)
        ranked_indices.first(remainder).each do |i|
          floored_scaled[i] += 1
        end
      end

      # Convert each floored integer back to a float with the given precision.
      def unscale_values(floored_scaled, multiplier)
        floored_scaled.map { |int| int.to_f / multiplier }
      end
    end
  end
end
