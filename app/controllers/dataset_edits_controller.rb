class DatasetEditsController < ApplicationController
  before_action :find_dataset
  before_action :find_previous_edits

  def edit
    @dataset_edit = current_user.dataset_edits.new
    @dataset_edit.build_source
  end

  def update
    @dataset_edit = current_user.dataset_edits.new(dataset_edit_params)

    if @dataset_edit.save
      redirect_to dataset_path(@dataset.area)
    else
      @dataset_edit.build_source

      render :edit
    end
  end

  private

  def find_dataset
    @dataset = Dataset.find(params[:dataset_id])
  end

  def find_previous_edits
    @dataset_edits = DatasetEditCollection.for(@dataset.id)
  end

  def dataset_edit_params
    params
      .require(:dataset_edit)
      .permit(:commit, :value, :key, :dataset_id, source_attributes: [:source_file])
  end
end
