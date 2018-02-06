require 'rails_helper'

describe CommitsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:dataset) { FactoryGirl.create(:dataset) }

  # POST dataset_edits.js
  #
  # This is a substep. In the next step you'll
  # see your changed edits and you can specify
  # a commit message.
  describe "#dataset_edits" do
    before do
      post :dataset_edits, params: {
        dataset_id: dataset.id,
        dataset_edit_form: {
          dataset_id: dataset.id,
          number_of_residences: 15,
          number_of_inhabitants: 50
        }
      }, format: :js, xhr: true
    end

    it "is succesful" do
      expect(response).to be_success
    end
  end

  describe "#create" do
    before do
      post :create, params: {
        dataset_id: dataset.id,
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
