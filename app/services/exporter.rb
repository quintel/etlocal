# Fetches data from an ETLocal server, runs Transformer to create a
# fully-functional dataset, and creates a dataset in a local copy of ETSource.
module Exporter
  DATASET_URL = "#{Rails.configuration.etsource_export_root}/api/v1".freeze

  class << self
    # Public: Exports an ETLocal dataset to an ETSource dataset.
    def export(dataset_ids, rebuild: true)
      response = RestClient.get(
        "#{DATASET_URL}/exports/#{dataset_ids}",
        accept: :json,
        content_type: :json
      )

      JSON.parse(response).each { |dataset| transform_dataset(dataset, rebuild) }
    rescue RestClient::ExceptionWithResponse
      puts "Failed to fetch data for #{dataset_ids}"
    end

    private

    def transform_dataset(dataset, rebuild)
      puts "Generating #{dataset['area']} with base set #{dataset['base_dataset']}"
      transformer = Transformer::DatasetGenerator.new(dataset)

      transformer.preserve_paths(%w[curves]) do
        transformer.destroy if rebuild
        transformer.generate
      end

      puts "Successfully analyzed and exported #{dataset['area']}"
    end
  end
end
