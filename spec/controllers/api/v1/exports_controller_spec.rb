require 'rails_helper'

describe Api::V1::ExportsController do
  let(:dataset) { Dataset.find('ameland') }

  it 'fetches a collection of dataset edits as json' do
    get :show, params: { area: dataset.area }, format: :json

    expect(JSON.parse(response.body)).to eq({
      'gas_consumption'                    => nil,
      'electricity_consumption'            => nil,
      'roof_surface_available_for_pv'      => nil,
      'number_of_cars'                     => 1062.598515994393,
      'number_of_residences'               => 10.0,
      'number_of_residences_with_solar_pv' => nil,
      'number_of_inhabitants'              => 10.0
    })
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
      get :show, params: { area: dataset.area }, format: :json

      expect(JSON.parse(response.body)).to eq({
        "gas_consumption"=>nil,
        "electricity_consumption"=>nil,
        "roof_surface_available_for_pv"=>nil,
        "number_of_cars"=>1.0,
        'number_of_residences_with_solar_pv' => nil,
        "number_of_residences"=>10.0,
        "number_of_inhabitants"=>10.0
      })
    end
  end
end
