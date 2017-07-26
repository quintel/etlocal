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
      @analyzes = DatasetAnalyzer.analyze(@atlas_dataset, params_for_calculation)
    rescue ArgumentError => error
      @error = error
    end

    render layout: false
  end

  def defaults
    render json: GraphAssumptions.get(:nl, true)
  end

  private

  def params_for_calculation
    JSON.parse(params.permit(:edits).fetch(:edits))
  end
end
