require 'rails_helper'

describe ChartsController do
  let(:user) { FactoryBot.create(:user) }
  let!(:sign_in_user) { sign_in(user) }

  it "fetches a chart" do
    post :data, params: {
      chart: {
        type: 'households_final_demand_electricity_demand'
      }
    }, format: :json

    body = JSON.parse(response.body)

    expect(body).to have_key("legend_type")
    expect(body).to have_key("layers")
    expect(body).to have_key("stops")
  end

  it "renders a 404 with incorrect type" do
    post :data, params: { chart: { type: "not_found"  }}, format: :json

    expect(response.code).to eq('404')
  end
end
