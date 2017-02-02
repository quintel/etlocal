class DatasetsController < ApplicationController
  before_action :find_dataset, except: :index

  def index
    @datasets = Dataset.all
  end

  def show
  end

  def edit
  end

  def update
    if @dataset.update_attributes(params_for_dataset)
      redirect_to dataset_path(@dataset)
    else
      render :edit
    end
  end

  private

  def params_for_dataset
    params.require(:dataset).permit(:title, :dataset_file, :commit_message)
  end

  def find_dataset
    @dataset = Dataset.find(params[:id])
  end
end
