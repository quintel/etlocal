require 'rails_helper'
require 'support/graph'

describe Api::V1::ExportsController do
  let(:dataset) { FactoryBot.create(:dataset) }
  let(:body) { JSON.parse(response.body)[0] }

  it 'fetches a collection of dataset edits as json' do
    get :show, params: { id: dataset.geo_id }, format: :json

    expect(body.fetch('present_number_of_apartments_before_1945')).to eq(84.0)
  end

  describe 'with edits' do
    let!(:dataset_edits) {
      2.times do |i|
        Timecop.freeze(Time.now + i)

        commit = FactoryBot.create(:commit, dataset: dataset)

        FactoryBot.create(:dataset_edit,
          key: 'number_of_cars',
          value: i + 1,
          commit: commit
        )
      end
    }

    it 'should render all the editable attributes of a dataset' do
      get :show, params: { id: dataset.geo_id }, format: :json

      expect(body.fetch('present_number_of_apartments_before_1945')).to eq(84.0)
    end

    it 'should render all the editable attributes of a dataset' do
      get :show, params: { id: dataset.geo_id }, format: :json

      expect(body.fetch('number_of_cars')).to eq(2.0)
    end
  end

  describe 'with special characters in the dataset name' do
    let(:dataset) do
      FactoryBot.create(:dataset, name: "háp-py\n∑®'&^-%_().  o… ")
    end

    it 'removes special characters' do
      get :show, params: { id: dataset.geo_id }, format: :json

      expect(body['area']).to eq('test1_hap_py_o')
    end
  end
end
