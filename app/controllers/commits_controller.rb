class CommitsController < ApplicationController
  layout false
  format 'js'

  before_action :authenticate_user!
  before_action :find_dataset

  # GET new
  def new
    @dataset_edit_form = DatasetEditForm.new(
      @dataset.editable_attributes.as_json
    )
  end

  # POST dataset_edits
  def dataset_edits
    @dataset_edit_form = DatasetEditForm.new(edit_params)
    @commit = @dataset_edit_form.submit(@dataset)
  end

  # POST create
  def create
    @commit = current_user.commits.new(commit_params)

    if @commit.save
      @dataset_edit_form = DatasetEditForm.new(
        @dataset.editable_attributes.as_json
      )

      flash.now[:success] = I18n.t("dataset_edits.success", dataset: @dataset.area)
    else
      @commit.build_source
    end
  end

  private

  def edit_params
    params
      .require(:edits)
      .permit(:dataset_id,
        *EditableAttributesCollection.keys)
  end

  def commit_params
    params
      .require(:change)
      .permit(:message, :dataset_id,
              source_attributes: [:source_file],
              dataset_edits_attributes: [:key, :value])
  end
end
