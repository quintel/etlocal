require 'rails_helper'
require 'support/graph'

describe Api::V1::ExportsController do
  let(:dataset) { FactoryGirl.create(:dataset) }
  let(:body) { JSON.parse(response.body)[0] }

  it 'fetches a collection of dataset edits as json' do
    get :show, params: { id: dataset.id }, format: :json

    expect(body.fetch('number_of_residences')).to eq(10.0)
  end

  describe 'with edits' do
    let!(:dataset_edits) {
      2.times do |i|
        Timecop.freeze(Time.now + i)

        commit = FactoryGirl.create(:commit, dataset: dataset)

        FactoryGirl.create(:dataset_edit,
          key: 'number_of_cars',
          value: i + 1,
          commit: commit
        )
      end
    }

    it 'should render all the editable attributes of a dataset' do
      get :show, params: { id: dataset.id }, format: :json

      expect(body.fetch('number_of_residences')).to eq(10.0)
    end

    it 'should render all the editable attributes of a dataset' do
      get :show, params: { id: dataset.id }, format: :json

      expect(body.fetch('number_of_cars')).to eq(2.0)
    end
  end
end
