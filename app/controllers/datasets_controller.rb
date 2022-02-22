class DatasetsController < ApplicationController
  layout false, only: %i[edit clone not_found]
  format 'js', only: %i(edit :clone)

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
      format.html { render 'datasets/index', layout: 'map'}
    end
  end

  # GET not_found.js
  def not_found
    @geo_id = params[:geo_id]
  end

  # GET search.json
  def search
    results = Dataset.fuzzy_search(params[:query], params[:country])
      .map { |d| { id: d.geo_id, name: d.name, group: I18n.t("groups.#{d.group}") } }
      .uniq
    render json: results
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

  # Renders an HTML partial containing information about the requested file.
  #
  # This requires the interface element key so that we can verify that the requested file really is
  # one of the files for which history available.
  #
  # GET /files/:interface_element_key/*file_key
  def git_file_info
    request.format = 'html'

    @dataset = Dataset.find_by!(geo_id: params[:id])
    element = InterfaceElement.find(params[:interface_element_key])

    authorize(@dataset)

    raise ActiveRecord::RecordNotFound, "Couldn't find InterfaceElement" unless element

    files = element.groups
      .select { |group| group.type == :files && group.paths.present? }
      .flat_map { |group| GitFiles.glob(@dataset.atlas_dataset, group.paths) }

    @file = files.find { |entry| entry.relative_path.to_s == params[:file_key] }

    raise ActiveRecord::RecordNotFound, "Couldn't find file" unless @file

    respond_to do |format|
      format.html { render layout: nil }
    end
  end
end
