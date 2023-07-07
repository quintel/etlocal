# frozen_string_literal: true

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

      migration_filename
    end

    private

    def migration_name
      @migration_name ||= [@target_dataset_id, @target_area_name, @migration_slug].join('_')
    end

    def migration_version
      @migration_version ||= DateTime.new.strftime('%Y%m%d%H%M%S')
    end

    def migration_filename
      "#{migration_version}_#{migration_name}.rb"
    end

    def create_migration
      # Load our custom data migration template
      template = Rails.root.join(
        'lib', 'generators', 'data_migration', 'templates', 'migration.rb.erb'
      ).read

      # Set variables to be rendered within the template
      migration_number = migration_version
      file_name = migration_name

      # Use ERB as the template renderer
      require 'erb'

      # 1. Render the template
      # 2. Add 'create_missing_datasets: true'
      # 3. Write the output to file
      Rails.root.join(
        'db', 'migrate', migration_filename
      ).write(
        ERB.new(template).result(binding).gsub(
          'commits_path)',
          'commits_path, create_missing_datasets: true)'
        )
      )

      # Create a directory with the same name as the migration
      Rails.root.join(
        'db', 'migrate', migration_filename[0, -3]
      ).mkdir
    end

    # Create CSV that holds the data we combined.
    # Will contain a header and one data row.
    def export_data_csv
      filename = Rails.root.join('db', 'migrate', migration_filename[0, -3], 'data.csv')
      headers = %w[name geo_id]
      headers.merge!(@combined_item_values.keys)

      require 'csv'

      CSV.open(filename, 'w', write_headers: true, headers: headers) do |writer|
        writer << [@target_area_name, @target_dataset_id].merge(@combined_item_values)
      end
    end

    # Create a commits file describing the area names of the datasets
    # that were used to create the combined one.
    def export_commit_yml
      Rails.root.join(
        'db', 'migrate', migration_filename[0, -3], 'commits.yml'
      ).write(
        { fields: [:all], message: "Optelling van de volgende gebieden: #{source_area_names}" }.to_yaml
      )
    end

  end

end
