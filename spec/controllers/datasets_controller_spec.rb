require 'rails_helper'
require 'support/graph'

describe DatasetsController do
  it 'redirect when not signed in' do
    get :index

    expect(response).to redirect_to(new_user_session_path)
  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:sign_in_user) { sign_in(user) }

    describe "#index" do
      it 'fetches index page' do
        get :index

        expect(response).to be_success
      end
    end

    describe "#edit" do
      let(:dataset) { FactoryGirl.create(:dataset, geo_id: 'test_1', area: "Test") }

      it "visits edit" do
        get :edit, params: { id: dataset.id }, format: :js, xhr: true

        expect(response).to be_success
      end
    end

    describe "#show" do
      let(:dataset) { FactoryGirl.create(:dataset, geo_id: 'test_1', area: "Test") }

      it "visits show" do
        get :show, params: { id: dataset.id }, format: :js, xhr: true

        expect(response).to be_success
      end
    end

    describe '#download' do
      let(:user) { FactoryGirl.create(:user) }
      let(:dataset) { FactoryGirl.create(:dataset,
                                         geo_id: 'test_1',
                                         area: "Test",
                                         user: user) }

      describe "insufficient data for an analyzes" do
        it 'downloads the dataset as a zip file' do
          get :download, params: { dataset_id: dataset.id }

          expect(JSON.parse(response.body)['error']).to include("can't be blank")
        end
      end

      describe "succesfully" do
        let!(:commit) {
          FactoryGirl.create(:initial_commit, dataset: dataset)
        }

        it 'downloads the dataset as a zip file' do
          get :download, params: { dataset_id: dataset.id }

          expect(response).to be_success
        end
      end
    end

    describe "#clone" do
      let(:user) { FactoryGirl.create(:user) }

      def clone_dataset
        post :clone, params: { dataset_id: dataset.id, format: 'js' }
      end

      describe "clones the dataset - when public" do
        let(:dataset) { FactoryGirl.create(:dataset,
                                           geo_id: 'test_1',
                                           area: "Test",
                                           user: user,
                                           public: true) }

        it "counts datasets to 2" do
          clone_dataset

          expect(Dataset.count).to eq(2)
        end
      end

      describe "can clone the dataset - when private - and the user's" do
        let(:dataset) { FactoryGirl.create(:dataset,
                                           geo_id: 'test_1',
                                           area: "Test",
                                           user: user,
                                           public: false) }

        it "counts datasets to 1" do
          clone_dataset

          expect(Dataset.count).to eq(2)
        end
      end

      describe "can't clone the dataset - when private - and not the user's" do
        let(:dataset) { FactoryGirl.create(:dataset,
                                           geo_id: 'test_1',
                                           area: "Test",
                                           user: FactoryGirl.create(:user),
                                           public: false) }

        it "counts datasets to 1" do
          expect { clone_dataset }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end
end
