class Api::V1::ExportsController < ApplicationController
  format 'json'

  before_action :find_dataset

  def show
    render json: @dataset.editable_attributes
  end
end
