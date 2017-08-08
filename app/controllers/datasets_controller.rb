class DatasetsController < ApplicationController
  layout 'map', only: :index

  before_action :authenticate_user!
  before_action :find_dataset, only: %i(calculate download)

  def index
    @datasets = Dataset.all
  end

  def calculate
    @atlas_dataset = Atlas::Dataset.find(@dataset.country)

    begin
      @analyzes = AnalyzesDecorator.decorate(
        DatasetAnalyzer.analyze(@atlas_dataset, params_for_calculation)
      )
    rescue ArgumentError => error
      @error = error
    end

    render layout: false
  end

  def download
    @dataset_downloader = DatasetDownloader.new(@dataset)

    if @dataset_downloader.validator.valid?
      send_data @dataset_downloader.download,
        filename: @dataset_downloader.zip_filename
    else
      render json: { error: @dataset_downloader.validator.message }
    end
  end

  def defaults
    render json: GraphAssumptions.get(:nl, true)
  end

  private

  def params_for_calculation
    JSON.parse(permitted_params.fetch(:edits))
  end

  def permitted_params
    params.require(:calculate).permit(:edits)
  end
end
