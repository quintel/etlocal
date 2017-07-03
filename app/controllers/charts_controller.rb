class ChartsController < ApplicationController
  format 'json'

  before_action :authenticate_user!

  def data
    chart_renderer = ChartRenderer.new(chart_params)

    if chart_renderer.valid?
      render json: chart_renderer.data
    else
      render json: { status: "not found" }, status: 404
    end
  end

  private

  def chart_params
    params.require(:chart).permit(:type)
  end
end
