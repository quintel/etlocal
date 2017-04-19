class CommitsController < ApplicationController
  layout false
  format 'js'

  before_action :authenticate_user!
  before_action :find_dataset

  # GET new
  def new
    @commit = current_user.commits.new
  end

  # POST dataset_edits
  def dataset_edits
    @commit = current_user.commits.new(edit_params)
    @filter = DatasetEditFilter.new(@dataset, @commit)

    if @filter.changed_edits.any?
      @commit.build_source
    end
  end

  # POST create
  def create
    @commit = current_user.commits.new(commit_params)
    @filter = DatasetEditFilter.new(@dataset, @commit)

    if @commit.save
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
              dataset_edits_attributes: [:key, :value])
  end

  def commit_params
    params
      .require(:change)
      .permit(:message, :dataset_id,
              source_attributes: [:source_file],
              dataset_edits_attributes: [:key, :value])
  end
end
