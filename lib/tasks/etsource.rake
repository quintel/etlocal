# frozen_string_literal: true

namespace :etsource do
  desc <<-DESC
    Exports changes of a dataset to ETSource

    Requires a DATASET argument. It exports data from a remote source which
    you can set in the .env file with the EXPORT_ROOT variable.

    Use DATASET=all to export all datasets, or provide specific dataset IDs.

    for localhost use:
    - localhost:3000

    for production use:
    - data.energytransitionmodel.com

    Optional argument TIME_CURVES_TO_ZERO, default true, does not scale
    timecurves when set to true.

    Optional argument REBUILD, default false, removes the dataset folder from
    ETSource before generating a new set when true. This means a new dataset id
    in ETSource is generated, the old one will be removed. Use true only when
    you want to force regeneration of all datasets.

    Optional argument BATCH_SIZE, default 10, controls how many datasets to export at once when using DATASET=all

  DESC

  task export: :environment do
    raise ArgumentError, 'DATASET= argument is missing' unless ENV['DATASET']

    rebuild = ENV['REBUILD'] == 'true'
    batch_size = ENV['BATCH_SIZE']&.to_i || 10

    if ENV['DATASET'] == 'all'
      # Export all datasets in batches
      total_datasets = Dataset.count
      puts "Exporting #{total_datasets} datasets in batches of #{batch_size}..."
      puts "REBUILD mode: #{rebuild ? 'ON (will regenerate all datasets)' : 'OFF (will preserve existing datasets)'}"

      Dataset.find_in_batches(batch_size: batch_size) do |batch|
        dataset_geo_ids = batch.map(&:geo_id).join(',')
        puts "Exporting batch: #{dataset_geo_ids} (#{batch.size} datasets)"

        begin
          Exporter.export(dataset_geo_ids, rebuild: rebuild)
        rescue => e
          puts "Failed to export batch #{dataset_geo_ids}: #{e.message}"
          puts "Continuing with next batch..."
        end
      end

      puts "Finished exporting all datasets"
    else
      Exporter.export(ENV['DATASET'], rebuild: rebuild)
    end
  end
end
