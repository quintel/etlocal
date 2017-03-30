require 'rails_helper'

describe ChartsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }

  it "fetches a chart" do
    post :data, params: { chart: { type: "electricity_consumption", layer: "municipalities" }}, format: :json

    expect(JSON.parse(response.body)).to eq([])
  end

  it "renders a 404 with incorrect type" do
    post :data, params: { chart: { type: "not_found", layer: "municipalities" }}, format: :json

    expect(response.code).to eq('404')
  end

  it "renders a 404 with incorrect layer" do
    post :data, params: { chart: { type: "electricity_consumption", layer: "not_found" }}, format: :json

    expect(response.code).to eq('404')
  end
end
