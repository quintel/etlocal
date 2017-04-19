class DatasetsController < ApplicationController
  layout 'map'

  before_action :authenticate_user!

  def index
    @datasets = Dataset.all
  end
end
