class Api::V1::ExportsController < ApplicationController
  format 'json'

  def show
    datasets = Dataset.where(geo_id: params[:id].split(','))

    json = datasets.map do |dataset|
      dataset.editable_attributes.as_json.merge(
        area: "#{dataset.geo_id}_#{dataset.normalized_name}",
        base_dataset: dataset.base_dataset,
        group: dataset.group
      )
    end

    render json: json
  end
end
