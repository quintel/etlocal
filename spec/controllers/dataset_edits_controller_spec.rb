require 'rails_helper'

describe DatasetEditsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }

  it 'visits the edit path' do
    get :edit, params: { dataset_area: dataset.key, attribute_name: 'number_of_buildings' }

    expect(response).to be_success
  end

  describe 'create a new dataset edit' do
    before do
      post :update, params: { dataset_area: dataset.key, attribute_name: 'number_of_buildings', dataset_edit: {
        source_attributes: { source_file: fixture_file_upload('test.xls') },
        dataset_id: dataset.id,
        key: 'number_of_buildings',
        commit: "Because of reasons",
        value: 2000
      }}
    end

    it 'creates a single source for the dataset edit' do
      expect(DatasetEdit.last.source).to_not be_blank
    end

    it 'creates a single source for the current user' do
      expect(user.sources.count).to eq(1)
    end

    it 'creates a single dataset edit for the current user' do
      expect(user.dataset_edits.count).to eq(1)
    end
  end

  describe "create a new dataset edit with an existing source" do
    it 'source count remains 1'
  end
end
