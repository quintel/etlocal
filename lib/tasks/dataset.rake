# frozen_string_literal: true

namespace :dataset do
  desc <<-DESC
    Combine multiple datasets together into a bigger one, for example municipalities into a province.

    Accepts the following arguments:
    - target_dataset_geo_id: Geo-id of region to combine data into, e.g.: 'PV20'
    - source_data_year: The year to which all source datasets should at least be updated.
        This is used to validate whether the dataset_geo_ids to combine from are up-to-date.
    - source_dataset_geo_ids: Geo-ids for regions that provide source-information to be combined, e.g.: 'GM306,GM307,GM308'.
    - target_area_name (optional): Name of region to combine into, e.g.: 'Groningen'
        If omitted the script will attempt to lookup the name of the dataset belonging to the given 'target_dataset_geo_id'
    - target_country_name (optional): Name of country of the target dataset, e.g.: 'nl2019'
        If omitted the script will attempt to lookup the country through the dataset belonging to the given target_dataset_geo_id.
    - migration_slug (optional): Name of migration to generate, e.g.: 'update_2019'
        If omitted the source_data_year will be used.

    Example:
      rails dataset:combine target_dataset_geo_id=PV20 source_data_year=2019
                            source_dataset_geo_ids=GM306,GM307,GM308 target_area_name=Groningen
                            migration_slug=update_2019
  DESC
  task combine: :environment do
    puts "\nInitializing DatasetCombiner with given datasets..."

    combiner = DatasetCombiner.new(
      target_dataset_geo_id: ENV.fetch('target_dataset_geo_id', nil),
      source_data_year: ENV.fetch('source_data_year', nil),
      source_dataset_geo_ids: ENV.fetch('source_dataset_geo_ids', nil).try(:split, ','),
      target_area_name: ENV.fetch('target_area_name', nil),
      target_country_name: ENV.fetch('target_country_name', nil),
      migration_slug: ENV.fetch('migration_slug', nil)
    )

    puts '✅ Dataset combiner initialized!'
    puts 'Combining datasets... '

    begin
      combiner.combine_datasets
    rescue StandardError => e
      puts '❌ Something went wrong while attempting to combine the datasets:'
      puts e.message
      puts "\n"

      exit
    end

    puts '✅ Datasets combined!'
    puts 'Exporting data...'

    begin
      migration_filename = combiner.export_data
    rescue StandardError => e
      puts '❌ Something went wrong while attempting to export the newly combined dataset:'
      puts e.message
      puts "\n"

      exit
    end

    puts '✅ Datasets exported!'
    puts "Migration file can be found at: #{migration_filename}\n\n"
    puts 'All done! Have a nice day :)'
  end

end
