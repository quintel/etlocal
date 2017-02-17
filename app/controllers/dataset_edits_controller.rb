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
      redirect_to dataset_path(@dataset.key)
    else
      render :edit
    end
  end

  private

  def find_dataset
    @dataset = Atlas::Dataset::Derived.find(params[:dataset_id])
  end

  def find_previous_edits
    @dataset_edits = DatasetEditCollection.for(params[:dataset_id])
  end

  def dataset_edit_params
    params
      .require(:dataset_edit)
      .permit(:commit, :value, :key, :area, source_attributes: [:source_file])
  end
end
