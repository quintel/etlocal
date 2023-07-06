# frozen_string_literal: true

namespace :dataset do
  desc <<-DESC
    Combine different datasets together into a bigger one, for example municipalities into a province.

    Accepts the following arguments:
    - target_dataset_id (mandatory): Geo-id of region to combine data into, e.g.: 'PV20'
    - source_data_year (mandatory): The year to which all source datasets should at least be updated.
        This is used to validate whether the dataset_ids to combine from are up-to-date.
    - source_dataset_ids: Geo-ids for regions that provide source-information to be combined, e.g.: 'GM306,GM307,GM308'.
        If omitted this will default to all regions that fall under the region of the given target_dataset_id.
    - name: Name of region to combine into, e.g.: 'Groningen'
        If omitted the system will attempt to derive this from the region of the given geo-id.
    - migration_name: Name of migration to generate, e.g.: 'update_2020'
        If omitted the system will attempt to derive this from the region of the given geo-id and the target year.

    Example:
      rails dataset:combine target_dataset_id=PV20 source_data_year=2023
    or
      rails dataset:combine target_dataset_id=PV20 source_data_year=2020 source_dataset_ids=GM306,GM307,GM308 name=Groningen migration_name=update_2020
  DESC
  task combine: :environment do
    combiner = DatasetCombiner(
      geo_id: ENV.fetch('geo_id', nil),
      data_year: ENV.fetch('data_year', nil),
      dataset_ids: ENV.fetch('dataset_ids', nil),
      name: ENV.fetch('name', nil),
      migration_name: ENV.fetch('migration_name', nil)
    )

    puts 'Dataset combiner initialized. Combining datasets...'

    combiner.combine_datasets

    puts 'Datasets combined. Generating migrations...'

    migration_filename = combiner.export_migrations

    puts "Migrations generated into file: #{migration_filename}\n\nAll done! Have a nice day :)"
  end

end
