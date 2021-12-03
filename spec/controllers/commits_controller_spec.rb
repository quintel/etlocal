require 'rails_helper'

describe CommitsController do
  let(:user) { FactoryBot.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:dataset) { FactoryBot.create(:dataset) }

  # POST dataset_edits.js
  #
  # This is a substep. In the next step you'll
  # see your changed edits and you can specify
  # a commit message.
  describe "#dataset_edits" do
    def request_dataset_edits
      post :dataset_edits, params: {
        dataset_id: dataset.id,
        dataset_edit_form: {
          dataset_id: dataset.id,
          number_of_residences: 15,
          number_of_inhabitants: 50
        }
      }, format: :js, xhr: true
    end

    describe " -> valid" do
      let(:dataset) { FactoryBot.create(:dataset, user: user) }

      it "is succesful" do
        request_dataset_edits

        expect(response).to be_successful
      end
    end

    describe " -> unauthorized" do
      let(:dataset) { FactoryBot.create(:dataset) }

      it "requires a user" do
        expect { request_dataset_edits }.to raise_error(Pundit::NotAuthorizedError)
      end
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
          dataset_edits_attributes: [
            {
              "key"=>"number_of_buildings",
              "value"=>"0.25"
            }
          ]
        }
      }

      it 'creates a dataset edit' do
        expect(DatasetEdit.count).to eq(1)
      end

      it 'creates a single dataset which belongs to a commit' do
        expect(user.commits.last.dataset_edits.count).to eq(1)
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
          dataset_edits_attributes: {
            "0"=>{
              "key"=>"number_of_buildings",
              "value"=>"0.25"
            },
            "1"=>{
              "key"=>"electricity_consumption",
              "value"=>""
            }
          }
        }
      }

      it 'creates a dataset edit' do
        expect(DatasetEdit.count).to eq(1)
      end

      it 'creates a single dataset which belongs to a commit' do
        expect(user.commits.last.dataset_edits.count).to eq(1)
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
