class DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_dataset, only: :show

  def index
    @datasets = Dataset.all
  end

  def show
    @dataset_edits = DatasetEditCollection.for(@dataset.area)
    @inputs        = InputsDecorator.decorate(@dataset.inputs)
    @editables     = AttributesDecorator.decorate(@dataset.editable)
  end
end
