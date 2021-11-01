# frozen_string_literal: true

module DatasetSource
  module ENTSO
    # Contains information about an ENTSO energy balance used as a data source for a Dataset.
    class File
      def self.key_map_config
        @key_map_config ||= YAML
          .load_file(Rails.root.join('config/source_keys/entso.yml'))
          .transform_values(&:invert).freeze
      end

      def self.energy_balance(csv_table)
        Map.new(
          csv_table.each_with_object({}) do |row, data|
            data[row[:siec]] ||= {}
            data[row[:siec]][row[:nrg_bal]] = row[:obs_value].to_f
          end,
          KeyMap.from_hash(key_map_config['rows']),
          KeyMap.from_hash(key_map_config['columns'])
        )
      end

      def self.from_dataset(dataset)
        new(dataset.geo_id, Rails.root.join('data', 'datasets', "#{dataset.geo_id}.csv"))
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
        @energy_balance ||= self.class.energy_balance(CSV.table(@path, converters: []))
      end
    end
  end
end
