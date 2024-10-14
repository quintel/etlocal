# frozen_string_literal: true

module DatasetSource
  module ENTSO
    # Contains information about an ENTSO energy balance used as a data source for a Dataset.
    class File
      def self.key_map_config
        @key_map_config ||= begin
          vals = YAML.load_file(Rails.root.join('config/source_keys/entso.yml'))

          {
            'column_groups' => vals['column_groups']
          }.freeze
        end
      end

      def self.energy_balance(csv_table)
        ColumnAggregatedMap.new(
          Map.new(
            csv_table.each_with_object({}) do |row, data|
              data[row[:nrg_bal]] = row.to_h.except!(:nrg_bal)
            end,
            KeyMap.identity,
            KeyMap.symbol
          ),
          key_map_config['column_groups']
        )
      end

      def self.from_dataset(dataset)
        new(dataset.geo_id, Rails.root.join('data', 'datasets', 'energy_balance', "#{dataset.geo_id}_energy_balance_enriched.csv"))
      end

      def initialize(geo_id, path)
        @geo_id = geo_id
        @path = path
      end

      def runtime
        @runtime ||= Runtime.new(@geo_id, energy_balance)
      end

      private

      # Creates a DatasetSource::Data using an ENTSO source CSV file, including mapping from
      # human-readable names (based on the XLSX version of the data) to those keys provided by the
      # CSV file.
      def energy_balance
        @energy_balance ||= self.class.energy_balance(CSV.table(@path, converters: [:numeric]))
      end
    end
  end
end
