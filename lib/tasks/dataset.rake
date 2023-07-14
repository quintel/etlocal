# frozen_string_literal: true

namespace :dataset do
  desc <<-DESC
    Combine different datasets together into a bigger one, for example municipalities into a province.

    Accepts the following arguments:
    - target_dataset_geo_id: Geo-id of region to combine data into, e.g.: 'PV20'
    - source_data_year: The year to which all source datasets should at least be updated.
        This is used to validate whether the dataset_geo_ids to combine from are up-to-date.
    - source_dataset_geo_ids: Geo-ids for regions that provide source-information to be combined, e.g.: 'GM306,GM307,GM308'.
    - target_area_name (optional): Name of region to combine into, e.g.: 'Groningen'
    - migration_slug (optional): Name of migration to generate, e.g.: 'update_2020'
        If omitted the source_data_year will be used.

    Example:
      rails dataset:combine target_dataset_geo_id=PV20 source_data_year=2019
                            source_dataset_geo_ids=GM306,GM307,GM308 target_area_name=Groningen
                            migration_slug=update_2020
  DESC
  task combine: :environment do
    combiner = DatasetCombiner.new(
      target_dataset_geo_id: ENV.fetch('target_dataset_geo_id', nil),
      source_data_year: ENV.fetch('source_data_year', nil).try(:to_i),
      source_dataset_geo_ids: ENV.fetch('source_dataset_geo_ids', nil).try(:split, ','),
      target_area_name: ENV.fetch('target_area_name', nil),
      migration_slug: ENV.fetch('migration_slug', nil)
    )

    puts "Dataset combiner initialized. Combining datasets...\n\n"

    begin
      combiner.combine_datasets
    rescue StandardError => e
      puts '!!! Something went wrong while attempting to combine the datasets! The following error was returned:'
      puts e.message
      puts "\n"

      exit
    end

    puts "Datasets combined. Exporting data...\n\n"

    begin
      migration_filename = combiner.export_data
    rescue StandardError => e
      puts 'Something went wrong while attempting to export the newly combined dataset! The following error was returned:'
      puts e.message
      puts "\n"

      exit
    end

    puts "Migrations generated into file: #{migration_filename}\n\nAll done! Have a nice day :)\n\n"
  end

end
