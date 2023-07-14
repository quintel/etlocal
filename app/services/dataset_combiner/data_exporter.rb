# frozen_string_literal: true

class DatasetCombiner

  # The DataExporter creates the migration file and exports the data of the combined dataset
  # to a CSV file so it can be processed by the migration anywhere. It also adds a commits
  # file containing the names of the source areas that were combined.
  #
  # All of the DataExporter's arguments are mandatory. For a description of the arguments
  # see the DatasetCombiner parent class.
  class DataExporter

    DATA_FILENAME = 'data.csv'
    COMMITS_FILENAME = 'commits.yml'

    def initialize(target_dataset_geo_id:, target_area_name:, migration_slug:, combined_item_values:, source_area_names:)
      @target_dataset_geo_id = target_dataset_geo_id
      @target_area_name = target_area_name
      @migration_slug = migration_slug
      @combined_item_values = combined_item_values
      @source_area_names = source_area_names
    end

    def perform
      create_migration

      export_data_file

      export_commits_file

      # For convenience we return the migration filename once performance is done
      migration_filename
    end

    private

    def migrate_directory
      @migrate_directory ||= Rails.root.join('db', 'migrate')
    end

    def migration_name
      @migration_name ||= [@target_dataset_geo_id, @target_area_name, @migration_slug].join('_').downcase
    end

    def migration_version
      @migration_version ||= DateTime.now.strftime('%Y%m%d%H%M%S')
    end

    def migration_filename
      @migration_filename ||= "#{migration_version}_#{migration_name}.rb"
    end

    def migration_directory
      @migration_directory ||= migrate_directory.join(migration_filename[0..-4])
    end

    def create_migration
      # Load our custom data migration template
      template = Rails.root.join(
        'lib', 'generators', 'data_migration', 'templates', 'migration.rb.erb'
      ).read

      # Set values to variables to be rendered within the template
      class_name = migration_name
      migration_number = migration_version
      file_name = "#{migration_name}.rb"

      # Use ERB to render the data migration template
      require 'erb'

      # 1. Render the template
      # 2. Add 'create_missing_datasets: true' to migration file
      # 3. Write the output to file
      migrate_directory.join(migration_filename).write(
        ERB
          .new(template)
          .result(binding)
          .gsub(
            'commits_path)',
            'commits_path, create_missing_datasets: true)'
          )
      )

      migration_directory.mkdir unless migration_directory.exist?
    end

    # Create CSV that contains the data that was combined and returned by the Dataset::ValueProcessor
    # The CSV will contain two lines: the first contains the header, the second contains the data
    def export_data_file
      migration_directory.join(DATA_FILENAME).write(
        <<~CSV_CONTENTS
          name,geo_id,#{@combined_item_values.keys.join(',')}
          #{@target_area_name},#{@target_dataset_geo_id},#{@combined_item_values.values.join(',')}
        CSV_CONTENTS
      )
    end

    # Create a commits file describing the area names of the datasets that were used to create the combined one
    def export_commits_file
      migration_directory.join(COMMITS_FILENAME).write(
        {
          fields: [:all],
          message: "Optelling van de volgende gebieden: #{@source_area_names.join(', ')}"
        }.to_yaml
      )
    end

  end

end
