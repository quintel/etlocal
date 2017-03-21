require 'rails_helper'

describe Api::V1::ExportsController do
  let(:dataset) { FactoryGirl.create(:dataset) }

  it 'fetches a collection of dataset edits as json' do
    get :show, params: { area: dataset.geo_id }, format: :json

    expect(JSON.parse(response.body).fetch('number_of_residences')).to eq(10.0)
  end

  describe 'with edits' do
    let!(:dataset_edits) {
      commit = FactoryGirl.create(:commit)

      FactoryGirl.create(:dataset_edit,
        key: 'number_of_cars',
        value: 2,
        commit: commit
      )

      # Make sure that the later dataset edit is created a bit later than the
      # previous one.
      sleep 1

      FactoryGirl.create(:dataset_edit,
        key: 'number_of_cars',
        value: 1,
        commit: commit
      )
    }

    it 'should render all the editable attributes of a dataset' do
      get :show, params: { area: dataset.geo_id }, format: :json

      expect(JSON.parse(response.body).fetch('number_of_residences')).to eq(10.0)
    end

    it 'should render all the editable attributes of a dataset' do
      get :show, params: { area: dataset.geo_id }, format: :json

      expect(JSON.parse(response.body).fetch('number_of_cars')).to eq(1.0)
    end
  end
end
