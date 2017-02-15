class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @datasets = Atlas::Dataset::Derived.all
  end

  def show
    @dataset       = Atlas::Dataset::Derived.find(params[:id])
    @dataset_edits = DatasetEditCollection.for(@dataset.key)
  end
end
