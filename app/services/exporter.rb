# Fetches data from an ETLocal server, runs Transformer to create a
# fully-functional dataset, and creates a dataset in a local copy of ETSource.
module Exporter
  DATASET_URL = "#{Rails.configuration.etsource_export_root}/api/v1".freeze

  # Public: Exports an ETLocal dataset to an ETSource dataset.
  def self.export(dataset_ids)
    response = RestClient.get(
      "#{DATASET_URL}/exports/#{dataset_ids}",
      accept: :json,
      content_type: :json
    )

    JSON.parse(response).each do |dataset|
      Transformer::DatasetGenerator.new(dataset).generate
      puts "Successfully analyzed and exported #{dataset[:area]}"
    end
  rescue RestClient::ExceptionWithResponse
    puts "Failed to fetch data for #{dataset_ids}"
  end
end
