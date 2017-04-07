require 'rails_helper'

describe DatasetEditCollection do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }

  let!(:edit_for_ameland) {
    FactoryGirl.create(:dataset_edit, key: 'number_of_cars', value: 5.0)
  }

  let!(:edit_for_ameland_same_key) {
    FactoryGirl.create(:dataset_edit, key: 'number_of_cars', value: 15.0)
  }

  let(:dataset_edit_collection) { DatasetEditCollection.for(dataset.area) }

  it 'fetches the edits for a dataset key' do
    expect(dataset_edit_collection.all).to include(edit_for_ameland)
  end

  it 'find latests edit for `number_of_cars`' do
    expect(dataset_edit_collection.find(:number_of_cars).value).to eq(5.0)
  end
end
