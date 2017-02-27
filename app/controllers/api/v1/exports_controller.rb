class Api::V1::ExportsController < ApplicationController
  format 'json'

  before_action :find_dataset

  def show
    edits = @dataset.dataset_edits.latest.each_with_object({}) do |edit, object|
      object[edit.key] = edit.value
    end

    render json: edits
  end
end
