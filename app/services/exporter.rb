module Exporter
  require 'rest-client'

  DATASET_URL = "#{ Rails.configuration.etsource_export_root }/api/v1".freeze

  # Module that exports a set of changes from a dataset directly to changes
  # inside of ETSource.
  def self.export(dataset)
    begin
      response = RestClient.get "#{ DATASET_URL }/exports/#{ dataset.geo_id }", accept: :json, content_type: :json

      store(dataset, JSON.parse(response))

      puts "Successfully analyzed and exported #{ dataset.area }"
    rescue RestClient::ExceptionWithResponse => e
      puts "Something went wrong with the analyzes and or exporting of #{ dataset.area }"
    end
  end

  def self.store(dataset, edits)
    analyzer = Transformer::Caster.cast(dataset, edits)

    # Set area attributes
    dataset.attributes = analyzer.fetch(:area)
    dataset.save

    dataset.graph_values.values = analyzer.fetch(:graph_values)
    dataset.graph_values.save
  end
end
