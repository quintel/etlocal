module Exporter
  require 'rest-client'

  DATASET_URL = "#{ Rails.configuration.etsource_export_root }/api/v1".freeze

  # Module that exports a set of changes from a dataset directly to changes
  # inside of ETSource.
  def self.export(dataset)
    begin
      response = RestClient.get "#{ DATASET_URL }/exports/#{ dataset.area }", accept: :json, content_type: :json

      store(dataset.area, JSON.parse(response))
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    end
  end

  def self.store(area, edits)
    dataset            = Atlas::Dataset::Derived.find(area)
    dataset.attributes = DatasetAnalyzer.analyze(edits)
    dataset.save
  end
end
