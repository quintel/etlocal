module Exporter
  require 'rest-client'

  DATASET_URL = "#{ Rails.configuration.etsource_export_root }/api/v1".freeze

  # Module that exports a set of changes from a dataset directly to changes
  # inside of ETSource.
  def self.export(dataset)
    begin
      response = RestClient.get "#{ DATASET_URL }/exports/#{ dataset.geo_id }", accept: :json, content_type: :json

      store(dataset, JSON.parse(response))
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    end
  end

  def self.store(dataset, edits)
    dataset.attributes = DatasetAnalyzer.analyze(dataset, edits)
    dataset.save
  end
end
