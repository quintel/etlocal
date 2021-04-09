class DatasetsController < ApplicationController
  layout false, only: %i[edit clone not_found]
  format 'js', only: %i[edit clone not_found]

  before_action :authenticate_user!, only: %i[download clone]
  before_action :find_dataset, only: %i(validate edit download clone)

  # GET index
  def index
    @datasets = Dataset.all

    render layout: 'map'
  end

  # GET edit.js
  def edit
    @dataset_edit_form = DatasetEditForm.new(
      @dataset.editable_attributes.as_json
    )

    @dataset_clones = policy_scope(Dataset).clones(@dataset, current_user)
  end

  # GET show.json
  def show
    dataset = Dataset.find_by(geo_id: params[:id], user: User.robot)

    respond_to do |format|
      format.json { render json: dataset }
      format.html { render template: 'datasets/index', layout: 'map' }
    end
  end

  # GET not_found.js
  def not_found
    @geo_id = params[:geo_id]
  end

  # GET search.json
  def search
    results = Dataset.fuzzy_search(params[:query])
    render json: results.map { |d| { id: d.geo_id, name: d.name } }.uniq
  end

  # POST download
  def download
    @dataset_downloader = DatasetDownloader.new(@dataset)

    authorize @dataset

    begin
      send_data @dataset_downloader.download,
        filename: @dataset_downloader.zip_filename
    rescue Refinery::IncalculableGraphError,
           Refinery::FailedValidationError,
           Atlas::QueryError,
           ArgumentError => error
      render json: { error: error }
    ensure
      @dataset_downloader.prune!
    end
  end

  # POST clone
  def clone
    authorize @dataset

    @cloned_dataset = DatasetCloner.clone!(@dataset, current_user)
  end
end
