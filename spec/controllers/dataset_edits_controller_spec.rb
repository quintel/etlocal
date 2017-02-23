require 'rails_helper'

describe DatasetEditsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }

  it 'visits the edit path' do
    get :edit, params: { dataset_area: dataset.key, attribute_name: 'number_of_buildings' }

    expect(response).to be_success
  end

  describe 'visits the edit path with an unknown key' do
    before do
      get :edit, params: { dataset_area: dataset.key, attribute_name: 'does-not-exist' }
    end

    it 'redirects' do
      expect(response).to redirect_to(dataset_path(dataset.key))
    end

    it 'sets a flash message' do
      expect(flash[:error]).to be_present
    end
  end

  describe 'create a new dataset edit' do
    before do
      post :update, params: {
        dataset_area: dataset.key,
        attribute_name: 'number_of_buildings',
        change: {
          source_attributes: { source_file: fixture_file_upload('test.xls') },
          dataset_edits_attributes: {"0"=>{
            "key"=>"number_of_buildings",
            "value"=>"0.25"
          }},
          dataset_area: dataset.key,
          message: "Because of reasons"
        }
      }
    end

    it 'creates a single source for the dataset edit' do
      expect(DatasetEdit.count).to eq(1)
    end

    it 'creates a single source for the current user' do
      expect(user.sources.count).to eq(1)
    end

    it 'creates a single dataset edit for the current user' do
      expect(user.dataset_edits.count).to eq(1)
    end

    it 'creates a single commit for the current user' do
      expect(user.commits.count).to eq(1)
    end
  end

  describe "create a new dataset edit with an existing source" do
    it 'source count remains 1'
  end
end
