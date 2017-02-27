module Exporter
  require 'rest-client'

  DATASET_URL = "https://beta-local.energytransitionmodel.com/api/v1".freeze

  # Module that exports a set of changes from a dataset directly to changes
  # inside of ETSource.
  def self.export(dataset)
    begin
      response = RestClient.get "#{ DATASET_URL }/export/#{ dataset.area }", accept: :json

      dataset            = Atlas::Dataset::Derived.find(dataset.area)
      dataset.attributes = DatasetAnalyzer.analyze(JSON.parse(response))
      dataset.save
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    end
  end
end
