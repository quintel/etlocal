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

      def self.energy_balance(csv_map)
        ColumnAggregatedMap.new(
          csv_map,
          key_map_config['column_groups']
        )
      end

      def self.from_dataset(dataset)
        base_path = Rails.root.join('data', 'datasets', 'energy_balance',
          "#{dataset.geo_id}_energy_balance_enriched")
        paths = ["#{base_path}.csv", "#{base_path}.gpg"]

        path = paths.find { |p| ::File.exist?(p) }

        unless path
          raise "Neither the CSV nor the encrypted file exists for dataset with geo_id: #{dataset.geo_id}"
        end

        new(dataset.geo_id, path)
      end

      # Decrypts the EB to a string using Atlas
      def self.decrypt(path)
        Atlas::EnergyBalance.decrypt(path)
      end

      def initialize(geo_id, path)
        @geo_id = geo_id
        @path = path
      end

      def runtime
        @runtime ||= Runtime.new(@geo_id, energy_balance)
      end

      # Maps for direct and decrypted csv's slightly differ: the decrypted csvs
      # use strings instead of symbols when getting parsed by CSV
      def map_for(csv_table)
        key = was_encrypted? ? 'nrg_bal' : :nrg_bal
        Map.new(
          csv_table.each_with_object({}) do |row, data|
            data[row[key]] = row.to_h.except!(key)
          end,
          KeyMap.identity,
          was_encrypted? ? KeyMap.identity : KeyMap.symbol
        )
      end

      private

      # Creates a DatasetSource::Data using an ENTSO source CSV file, including mapping from
      # human-readable names (based on the XLSX version of the data) to those keys provided by the
      # CSV file.
      def energy_balance
        @energy_balance ||= self.class.energy_balance(map_for(parsed_csv))
      end

      def parsed_csv
        if was_encrypted?
          CSV.parse(File.decrypt(@path), converters: [:numeric], headers: true)
        else
          CSV.table(@path, converters: [:numeric])
        end
      end

      def was_encrypted?
        encrypted
      end

      def encrypted
        @encrypted ||= ::File.extname(@path) == '.gpg'
      end
    end
  end
end
