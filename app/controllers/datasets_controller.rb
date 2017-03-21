class DatasetsController < ApplicationController
  format 'js', only: :show
  layout 'map', only: :index

  before_action :authenticate_user!
  before_action :find_dataset, only: :show

  def index
    @datasets = Dataset.all
  end

  def show
    @dataset_edits = DatasetEditCollection.for(@dataset.geo_id)

    render layout: false
  end
end
