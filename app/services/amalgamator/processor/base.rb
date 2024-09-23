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

      # Rounds values to 8 decimals and replaces nil with 0.0
      def round_item_values(item_values)
        item_values.transform_values! { |value| value.present? ? value.round(8) : 0.0 }
      end
    end
  end
end
