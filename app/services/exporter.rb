module Exporter
  require 'rest-client'

  DATASET_URL = "#{Rails.configuration.etsource_export_root}/api/v1".freeze

  # Module that exports a set of changes from a dataset directly to changes
  # inside of ETSource.
  def self.export(dataset_ids)
    begin
      result = RestClient.get("#{DATASET_URL}/exports/#{dataset_ids}",
                              accept: :json,
                              content_type: :json)

      JSON.parse(result).each do |dataset|
        Transformer::DatasetGenerator.new(dataset).generate

        puts "Successfully analyzed and exported #{dataset[:area]}"
      end
    rescue RestClient::ExceptionWithResponse => e
      puts "Something went wrong with the analyzes and or exporting of #{dataset_ids}"
    end
  end
end
