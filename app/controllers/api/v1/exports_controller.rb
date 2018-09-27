class Api::V1::ExportsController < ApplicationController
  format 'json'

  def show
    datasets = Dataset.where(id: params[:id].split(','))

    json = datasets.map do |dataset|
      dataset.editable_attributes.as_json.merge(
        area: "#{dataset.geo_id}_#{dataset.name.downcase.tr(' ', '_')}",
        base_dataset: dataset.country,
        group: dataset.group
      )
    end

    render json: json
  end
end
