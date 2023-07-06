class DatasetCombiner

  class MigrationGenerator

    def perform(target_dataset_id:, target_area_name:, migration_slug:, combined_item_values:, source_area_names:)
      @target_dataset_id = target_dataset_id
      @target_area_name = target_area_name
      @migration_slug = migration_slug
      @combined_item_values = combined_item_values
      @source_area_names = source_area_names

      create_migration

      export_data_csv

      export_commit_yml

      @migration_filename
    end

    def migration_name
      @migration_name ||= "#{@target_dataset_id}_#{@target_area_name}_#{@migration_slug}"
    end

    def create_migration
      @migration_filename = DataMigrationGenerator.create_migration_file(migration_name)

      File.write(
        @migration_filename,
        File.read(@migration_filename).gsub(
          'commits_path)',
          'commits_path, create_missing_datasets: true)'
        )
      )
    end

    def export_data_csv
      filename = Rails.root.join('db', 'migrate', @migration_filename, 'data.csv')
      headers = %w[name geo_id]
      headers.merge!(@combined_item_values.keys)

      require 'csv'

      CSV.open(filename, 'w', write_headers: true, headers: headers) do |writer|
        writer << [@target_area_name, @target_dataset_id].merge(@combined_item_values)
      end
    end

    def export_commit_yml
      filename = Rails.root.join('db', 'migrate', @migration_filename, 'commits.yml')

      File.write(
        filename,
        { fields: [:all], message: "Optelling van de volgende gebieden: #{source_area_names}" }.to_yaml
      )
    end

  end

end
