class Api::V1::ExportsController < ApplicationController
  format 'json'

  def show
    datasets = Dataset.where(id: params[:id].split(','))

    json = datasets.map do |dataset|
      dataset.editable_attributes.as_json.merge(
        area: "#{dataset.geo_id}_#{dataset.normalized_name}",
        base_dataset: dataset.base_dataset,
        group: dataset.group,
        time_curves_to_zero: params[:time_curves_to_zero]
      )
    end

    render json: json
  end
end
