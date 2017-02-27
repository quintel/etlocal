class DatasetEditsController < ApplicationController
  before_action :find_dataset
  before_action :find_dataset_attribute
  before_action :find_previous_edits

  def edit
    @commit = current_user.commits.new
    @commit.build_source
    @dataset_edit = @commit.dataset_edits.build(key: params[:attribute_name])
  end

  def update
    @commit = current_user.commits.new(commit_params)

    if @commit.save
      redirect_to dataset_path(@dataset.area), flash: {
        success: I18n.t("dataset_edits.success",
          key: @commit.dataset_edits.last.key,
          value: @commit.dataset_edits.last.value
        )
      }
    else
      @commit.build_source
      @dataset_edit = @commit.dataset_edits.last

      render :edit
    end
  end

  private

  def find_dataset_attribute
    unless @dataset.attribute_exists?(params[:attribute_name])
      flash[:error] = I18n.t("dataset_edits.flash.attribute_not_found",
                              attribute: params[:attribute_name])

      redirect_to dataset_path(@dataset.area)
    end
  end

  def find_previous_edits
    @dataset_edits = DatasetEditCollection.for(@dataset.area)
  end

  def commit_params
    params
      .require(:change)
      .permit(:message, :dataset_area,
              source_attributes: [:source_file],
              dataset_edits_attributes: [:key, :value])
  end
end
