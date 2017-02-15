class DatasetEditsController < ApplicationController
  before_action :find_dataset

  def edit
    @dataset_edit = current_user.dataset_edits.new
    @dataset_edit.build_source
  end

  def update
    @dataset_edit = current_user.dataset_edits.new(dataset_edit_params)

    if @dataset_edit.save
      redirect_to datasets_path
    else
      render :edit
    end
  end

  private

  def find_dataset
    @dataset = Atlas::Dataset::Derived.find(params[:dataset_id])
  end

  def dataset_edit_params
    params
      .require(:dataset_edit)
      .permit(:commit, :value, :key, :area, source_attributes: [:source_file])
  end
end
