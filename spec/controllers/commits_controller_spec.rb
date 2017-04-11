require 'rails_helper'

describe CommitsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:dataset) { FactoryGirl.create(:dataset) }

  describe "when signed in" do
    it 'fetches the show page' do
      get :new, params: { dataset_area: dataset.geo_id }, format: :js, xhr: true

      expect(response).to be_success
    end

    it 'fetches the show page as js' do
      get :new, params: { dataset_area: dataset.geo_id }, format: :js, xhr: true

      expect(response).to be_success
    end

    describe 'redirects to root page when a dataset is not found' do
      before do
        get :new, params: { dataset_area: "does-not-exist" }, format: :js, xhr: true
      end

      it 'redirects' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets flash message' do
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "#create" do
    before do
      post :create, params: {
        dataset_area: dataset.geo_id,
        change: {
          dataset_id: dataset.id,
          message: "Because of reasons"
        }.merge(commit_params)
      }, format: :js, xhr: true
    end

    describe 'create a new commit' do
      let(:commit_params) {
        {
          source_attributes: { source_file: fixture_file_upload('test.xls') },
          dataset_edits_attributes: [
            {
              "key"=>"gas_consumption",
              "value"=>"0.25"
            }
          ]
        }
      }

      it 'creates a single source for the dataset edit' do
        expect(DatasetEdit.count).to eq(1)
      end

      it 'creates a single dataset which belongs to a commit' do
        expect(user.commits.last.dataset_edits.count).to eq(1)
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

    describe 'create a new commit with a single invalid edit' do
      let(:commit_params) {
        {
          source_attributes: { source_file: fixture_file_upload('test.xls') },
          dataset_edits_attributes: {
            "0"=>{
              "key"=>"gas_consumption",
              "value"=>"0.25"
            },
            "1"=>{
              "key"=>"electricity_consumption",
              "value"=>""
            }
          }
        }
      }

      it 'creates a single source for the dataset edit' do
        expect(DatasetEdit.count).to eq(1)
      end

      it 'creates a single dataset which belongs to a commit' do
        expect(user.commits.last.dataset_edits.count).to eq(1)
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

    describe "create a dataset edit without specifying a source" do
      let(:commit_params) {
        {
          source_attributes: { },
          dataset_edits_attributes: {
            "0"=>{
              "key"=>"gas_consumption",
              "value"=>"0.25"
            }
          }
        }
      }

      it 'creates a single source for the dataset edit' do
        expect(DatasetEdit.count).to eq(1)
      end

      it 'creates no sources for the current user' do
        expect(user.sources.count).to eq(0)
      end

      it 'creates a single dataset edit for the current user' do
        expect(user.dataset_edits.count).to eq(1)
      end

      it 'creates a single commit for the current user' do
        expect(user.commits.count).to eq(1)
      end
    end
  end

  describe "create a new dataset edit with an existing source" do
    it 'source count remains 1'
  end
end
