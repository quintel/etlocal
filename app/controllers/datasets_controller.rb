class DatasetsController < ApplicationController
  layout 'map', only: :index

  before_action :authenticate_user!

  def index
    @datasets = Dataset.all
  end

  def defaults
    render json: GraphAssumptions.get(:nl, true)
  end
end
