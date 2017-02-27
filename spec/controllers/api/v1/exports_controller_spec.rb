require 'rails_helper'

describe Api::V1::ExportsController do
  let(:dataset) { Dataset.find('ameland') }

  it 'fetches a collection of dataset edits as json' do
    get :show, params: { area: dataset.area }, format: :json

    expect(JSON.parse(response.body)).to eq({})
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

    it 'should render the attributes of an edit' do
      get :show, params: { area: dataset.area }, format: :json

      expect(JSON.parse(response.body)).to eq({'number_of_cars' => '1'})
    end
  end
end
