class DatasetsController < ApplicationController
  format 'js', only: :show
  layout 'map', only: :index

  before_action :authenticate_user!
  before_action :find_dataset, only: :show

  def index
    @datasets = Dataset.all
  end

  def show
    @commit        = @dataset.commits.new
    @dataset_edits = DatasetEditCollection.for(@dataset.geo_id)

    Dataset::EDITABLE_ATTRIBUTES.each do |key, _|
      @commit.dataset_edits.build(key: key)
    end

    render layout: false
  end
end
