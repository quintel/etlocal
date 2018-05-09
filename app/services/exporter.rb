module Exporter
  require 'rest-client'

  DATASET_URL = "#{ Rails.configuration.etsource_export_root }/api/v1".freeze

  # Module that exports a set of changes from a dataset directly to changes
  # inside of ETSource.
  def self.export(dataset_id)
    begin
      response = JSON.parse(
        RestClient.get("#{DATASET_URL}/exports/#{dataset_id}",
                       accept: :json,
                       content_type: :json)
      )

      Transformer::DatasetGenerator.new(response).generate

      puts "Successfully analyzed and exported #{response[:area]}"
    rescue RestClient::ExceptionWithResponse => e
      puts "Something went wrong with the analyzes and or exporting of #{dataset_id}"
    end
  end
end
