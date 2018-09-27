class CommitsController < ApplicationController
  layout false
  format 'js'

  before_action :authenticate_user!
  before_action :find_dataset
  before_action :find_clones, only: %i(dataset_edits create)

  # GET new
  def new
    @dataset_edit_form = DatasetEditForm.new(
      @dataset.editable_attributes.as_json
    )
  end

  # POST dataset_edits
  def dataset_edits
    authorize @dataset, :update?

    @dataset_edit_form = DatasetEditForm.new(dataset_edit_params.to_h)
    @commit = @dataset_edit_form.submit(@dataset)
  end

  # POST create
  def create
    @commit = current_user.commits.new(commit_params)

    if @commit.save
      @dataset_edit_form = DatasetEditForm.new(
        @dataset.editable_attributes.as_json
      )

      flash.now[:success] = I18n.t(
        'dataset_edits.success',
        dataset: @dataset.name
      )
    else
      @commit.build_source
    end
  end

  private

  def dataset_edit_params
    params
      .require(:dataset_edit_form)
      .permit(:dataset_id,
        *EditableAttributesCollection.items.map(&:key)
      )
      .reject { |_, val| val.blank? }
  end

  def commit_params
    params
      .require(:change)
      .permit(:message, :dataset_id,
              source_attributes: [:source_file],
              dataset_edits_attributes: [:key, :value])
  end

  def find_clones
    @dataset_clones = policy_scope(Dataset).clones(@dataset, current_user)
  end
end
