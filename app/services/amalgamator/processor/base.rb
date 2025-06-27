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

      # Adjusts the flexible shares in the group if applicable. This method applies the Hare-Niemeyer method to redistribute
      # the 'remainder' of a share group's total based on the 'entitlement' weights of member shares.
      def adjust_flexible_shares(dataset_c_values, precision: 8)
        InterfaceElement.items.each do |item|
          next unless item.flexible && item.group&.items&.length.to_i > 1

          group_items   = item.group.items
          flexible_item = group_items.find(&:flexible)

          if group_items.select(&:flexible).length > 1
            log_error(item, "Multiple flexible shares in #{item.group.header}")
            next
          end

          # compute other members’ sum
          other_keys   = group_items.reject { |gi| gi == flexible_item }.map(&:key)
          other_values = other_keys.map { |k| dataset_c_values[k].to_f }
          flex_value = 1.0 - other_values.sum

          # assemble raw_group in group_items order
          raw_group = group_items.map do |gi|
            gi == flexible_item ? flex_value : dataset_c_values[gi.key].to_f
          end

          # floor & redistribute inside group
          rounded_group = smart_floor(raw_group, precision: precision)

          # write back into dataset_c_values
          group_items.each_with_index do |gi, idx|
            dataset_c_values[gi.key] = rounded_group[idx]
          end

        end

        dataset_c_values
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

      # Rounds values to 8 decimals and replaces nil with 0.0
      def round_item_values(item_values)
        item_values.transform_values! { |value| value.present? ? value.round(8) : 0.0 }
      end
    end
  end
end
