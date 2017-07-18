require 'rails_helper'

describe ChartsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }

  before do
    2.times do |value|
      dataset = FactoryGirl.create(:dataset, geo_id: "GM000#{ value }")
      commit  = FactoryGirl.create(:commit, dataset: dataset)

      FactoryGirl.create(:dataset_edit,
        key: 'electricity_consumption',
        value: value + 1,
        commit: commit
      )
    end
  end

  it "fetches a chart" do
    post :data, params: { chart: { type: "electricity_consumption" }}, format: :json

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
