class DatasetsController < ApplicationController
  layout 'map', only: :index

  before_action :authenticate_user!

  def index
    @datasets = Dataset.all
  end

  def calculate
    @dataset = Dataset.find_by(geo_id: params[:dataset_area])
    @atlas_dataset = Atlas::Dataset.find(@dataset.country)

    begin
      render json: DatasetAnalyzer.analyze(
        @atlas_dataset, @dataset.editable_attributes.as_json)
    rescue ArgumentError => e
      render json: { error: e }
    end
  end

  def defaults
    render json: GraphAssumptions.get(:nl, true)
  end
end
