# frozen_string_literal: true

namespace :dataset do
  desc <<-DESC
    Combine different datasets together into a bigger one, for example municipalities into a province.

    Accepts the following arguments:
    - target_dataset_id: Geo-id of region to combine data into, e.g.: 'PV20'
    - source_data_year: The year to which all source datasets should at least be updated.
        This is used to validate whether the dataset_ids to combine from are up-to-date.
    - source_dataset_ids: Geo-ids for regions that provide source-information to be combined, e.g.: 'GM306,GM307,GM308'.
    - target_area_name: Name of region to combine into, e.g.: 'Groningen'
    - migration_slug (optional): Name of migration to generate, e.g.: 'update_2020'
        If omitted the source_data_year will be used.

    Example:
      rails dataset:combine target_dataset_id=PV20 source_data_year=2023
    or
      rails dataset:combine target_dataset_id=PV20 source_data_year=2020
                            source_dataset_ids=GM306,GM307,GM308 target_area_name=Groningen
                            migration_name=update_2020
  DESC
  task combine: :environment do
    combiner = DatasetCombiner(
      target_dataset_id: ENV.fetch('target_dataset_id', nil),
      source_data_year: ENV.fetch('source_data_year', nil),
      source_dataset_ids: ENV.fetch('source_dataset_ids', []).split(','),
      target_area_name: ENV.fetch('target_area_name', nil),
      migration_slug: ENV.fetch('migration_slug', nil)
    )

    puts 'Dataset combiner initialized. Combining datasets...'

    combiner.combine_datasets

    puts 'Datasets combined. Exporting data...'

    migration_filename = combiner.export_data

    puts "Migrations generated into file: #{migration_filename}\n\nAll done! Have a nice day :)"
  end

end
