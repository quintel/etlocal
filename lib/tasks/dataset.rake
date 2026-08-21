# frozen_string_literal: true

require 'amalgamator/batch_combiner'
require 'amalgamator/combiner'
require 'amalgamator/separator'
require 'amalgamator/dataset_exporter'

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
    - target_parent_name (optional): Name of country of the target dataset, e.g.: 'nl2019'
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

    combiner = Amalgamator::Combiner.new(
      target_dataset_geo_id: ENV.fetch('target_dataset_geo_id', nil),
      source_data_year: ENV.fetch('source_data_year', nil),
      source_dataset_geo_ids: ENV.fetch('source_dataset_geo_ids', nil).try(:split, ','),
      target_area_name: ENV.fetch('target_area_name', nil),
      target_parent_name: ENV.fetch('target_parent_name', nil),
      migration_slug: ENV.fetch('migration_slug', nil)
    )

    puts 'Dataset combiner initialized!'
    puts 'Combining datasets... '

    combiner.result

    puts 'Datasets combined!'
    puts 'Exporting data...'

    migration_filename = combiner.export_data

    puts 'Datasets exported!'
    puts "Migration file can be found at: #{migration_filename}\n\n"
    puts 'All done! Have a nice day :)'
  end

  desc <<-DESC
    Combine many datasets into several bigger ones in one go, for example all municipalities into
    all provinces, or all municipalities into all RES regions. Which datasets belong together is
    read from a mapping CSV with one row per source region.

    Accepts the following arguments:
    - mapping_file: Path to the CSV mapping source regions onto target regions.
    - source_geo_id_column: Header (or 1-based position) of the column holding the source geo-ids,
        e.g.: 'gemeenten|Code'. A header only has to match part of the actual header.
    - target_geo_id_column: Header (or position) of the column holding the target geo-ids,
        e.g.: 'Provincies|Code'.
    - source_data_year: The year to which all source datasets should at least be updated.
    - target_name_column (optional): Header (or position) of the column holding the target names.
        If omitted the names of the existing target datasets are used.
    - target_parent_name (optional): Name of the country of the target datasets, e.g.: 'nl2023'.
        If omitted the parent of each existing target dataset is used.
    - migration_slug (optional): Name of the migrations to generate, e.g.: 'heat_pump_update'.
        If omitted the source_data_year will be used.
    - only (optional): Only combine these target geo-ids, e.g.: 'PV20,PV21'.
    - except (optional): Skip these target geo-ids, e.g.: 'PV20,PV21'.
    - dry_run (optional): Report what would be combined without writing any migration.
    - force (optional): Replace migrations generated earlier for the same target and slug.
    - allow_missing_sources (optional): Continue when a source geo-id has no dataset. Beware that
        such a region is then silently left out of the sum.

    Example:
      rails dataset:combine_all
        mapping_file='../etdataset/pipelines/config/CBS Gebieden in Nederland 2023 - ETM version.csv'
        source_geo_id_column='gemeenten|Code' target_geo_id_column='Provincies|Code'
        source_data_year=2023 target_parent_name=nl2023 migration_slug=heat_pump_update
  DESC
  task combine_all: :environment do
    flag = ->(name) { ActiveModel::Type::Boolean.new.cast(ENV.fetch(name, nil)) || false }

    puts "\nInitializing BatchCombiner with the given mapping..."

    batch_combiner = Amalgamator::BatchCombiner.new(
      mapping_file: ENV.fetch('mapping_file', nil),
      source_geo_id_column: ENV.fetch('source_geo_id_column', nil),
      target_geo_id_column: ENV.fetch('target_geo_id_column', nil),
      source_data_year: ENV.fetch('source_data_year', nil),
      target_name_column: ENV.fetch('target_name_column', nil),
      target_parent_name: ENV.fetch('target_parent_name', nil),
      migration_slug: ENV.fetch('migration_slug', nil),
      only: ENV.fetch('only', nil).try(:split, ','),
      except: ENV.fetch('except', nil).try(:split, ','),
      dry_run: flag.call('dry_run'),
      force: flag.call('force'),
      allow_missing_sources: flag.call('allow_missing_sources')
    )

    puts 'Batch combiner initialized!'

    batch_combiner.perform

    puts "\nAll done! Have a nice day :)"
  end

  desc <<-DESC
    Separate datasets by subtracting one dataset from another.

    Accepts the following arguments:
    - target_dataset_geo_id: Geo-id of the dataset to separate data from, e.g.: 'PV20'.
    - source_dataset_geo_ids: Geo-id of the dataset to subtract, e.g.: 'GM306'.
    - source_data_year: The year to which all source datasets should at least be updated.
    - migration_slug (optional): Name of migration to generate, e.g.: 'update_2019'
        If omitted the source_data_year will be used.

    Example:
      rails dataset:separate target_dataset_geo_id=PV20 source_dataset_geo_id=GM306 source_data_year=2019
  DESC
  task separate: :environment do
    puts "\nInitializing DatasetSeparator with given datasets..."

    separator = Amalgamator::Separator.new(
      target_dataset_geo_id: ENV.fetch('target_dataset_geo_id', nil),
      source_dataset_geo_ids: ENV.fetch('source_dataset_geo_ids', nil),
      source_data_year: ENV.fetch('source_data_year', nil)
    )

    puts 'Dataset separator initialized!'
    puts 'Separating datasets... '

    separator.result

    puts 'Datasets separated!'
    puts 'Exporting data...'

    migration_filename = separator.export_data

    puts 'Datasets exported!'
    puts "Migration file can be found at: #{migration_filename}\n\n"
    puts 'All done! Have a nice day :)'
  end
end
