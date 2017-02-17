class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @datasets = Dataset.all
  end

  def show
    @dataset = Dataset.find(params[:id])
  end
end
