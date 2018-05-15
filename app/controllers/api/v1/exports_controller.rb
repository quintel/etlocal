class Api::V1::ExportsController < ApplicationController
  format 'json'

  def show
    datasets = Dataset.where(id: params[:id].split(','))

    json = datasets.map do |dataset|
      dataset.editable_attributes.as_json.merge(
        area: dataset.area.downcase,
        base_dataset: dataset.country
      )
    end

    render json: json
  end
end
