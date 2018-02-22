class DatasetsController < ApplicationController
  layout false, only: %i(edit clone)
  format 'js', only: %i(edit :clone)

  before_action :authenticate_user!
  before_action :find_dataset, only: %i(validate edit download defaults clone)

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
    dataset = Dataset.find_by(geo_id: params[:id])

    render json: dataset
  end

  # POST download
  def download
    @dataset_downloader = DatasetDownloader.new(@dataset)

    authorize @dataset

    if @dataset_downloader.validator.valid?
      send_data @dataset_downloader.download,
        filename: @dataset_downloader.zip_filename
    else
      render json: {
        error: @dataset_downloader.validator.errors.full_messages.join(', ')
      }
    end
  end

  # POST clone
  def clone
    authorize @dataset

    @cloned_dataset = DatasetCloner.clone!(@dataset, current_user)
  end

  # GET defaults
  def defaults
    render json: GraphAssumptions.get(@dataset, :nl)
  end

  private

  def permitted_params
    params.require(:dataset_edit_form).permit(
      :dataset_id, *EditableAttributesCollection.keys
    ).reject{|_, v| v.blank? }
  end
end
