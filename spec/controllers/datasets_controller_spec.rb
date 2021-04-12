require 'rails_helper'
require 'support/graph'

describe DatasetsController do
  describe "when signed in" do
    let(:user) { FactoryBot.create(:user) }
    let!(:sign_in_user) { sign_in(user) }

    describe "#index" do
      it 'fetches index page' do
        get :index

        expect(response).to be_successful
      end
    end

    describe "#edit" do
      let(:dataset) { FactoryBot.create(:dataset, geo_id: 'test_1', name: "Test") }

      it "visits edit" do
        get :edit, params: { id: dataset.id }, format: :js, xhr: true

        expect(response).to be_successful
      end
    end

    describe "#show" do
      let(:dataset) { FactoryBot.create(:dataset, geo_id: 'test_1', name: "Test") }

      it 'responds to json' do
        get :show, params: { id: dataset.id }, format: :json, xhr: true

        expect(response).to be_successful
      end

      it 'responds to html' do
        get :show, params: { id: dataset.id }

        expect(response).to be_successful
      end
    end

    describe '#search' do
      subject do
        get :search, params: { query: query }, format: :json, xhr: true
        response
      end

      let(:dataset) { FactoryBot.create(:dataset, geo_id: 'test_1', name: "Test") }

      context 'when there is one match' do
        before { dataset }
        let(:query) { dataset.geo_id }

        it 'is successful' do
          expect(subject).to be_successful
        end

        it 'returns the dataset' do
          expect(JSON.parse(subject.parsed_body)[0]).to include({'id'=> dataset.geo_id, 'name'=> dataset.name })
        end

        it 'returns one object' do
          expect(JSON.parse(subject.parsed_body).length).to eq(1)
        end
      end

      context 'when there are no search matches' do
        let(:query) { 'nothing' }

        it 'is successful' do
          expect(subject).to be_successful
        end

        it 'returns an empty json' do
          expect(subject.parsed_body).to eq '[]'
        end
      end
    end

    describe '#download' do
      let(:user) { FactoryBot.create(:user) }
      let(:dataset) { FactoryBot.create(:dataset,
                                         geo_id: 'test_1',
                                         name: "Test",
                                         user: user) }

      describe "insufficient data for an analyzes" do
        it 'downloads the dataset as a zip file'
      end

      describe "succesfully" do
        let!(:commit) {
          FactoryBot.create(:initial_commit, dataset: dataset)
        }

        it 'downloads the dataset as a zip file'
      end
    end

    describe "#clone" do
      let(:user) { FactoryBot.create(:user) }

      def clone_dataset
        post :clone, params: { dataset_id: dataset.id, format: 'js' }
      end

      describe "clones the dataset - when public" do
        let(:dataset) { FactoryBot.create(:dataset,
                                           geo_id: 'test_1',
                                           name: "Test",
                                           user: user,
                                           public: true) }

        it "counts datasets to 2" do
          clone_dataset

          expect(Dataset.count).to eq(2)
        end
      end

      describe "can clone the dataset - when private - and the user's" do
        let(:dataset) { FactoryBot.create(:dataset,
                                           geo_id: 'test_1',
                                           name: "Test",
                                           user: user,
                                           public: false) }

        it "counts datasets to 1" do
          clone_dataset

          expect(Dataset.count).to eq(2)
        end
      end

      describe "can't clone the dataset - when private - and not the user's" do
        let(:dataset) { FactoryBot.create(:dataset,
                                           geo_id: 'test_1',
                                           name: "Test",
                                           user: FactoryBot.create(:user),
                                           public: false) }

        it "counts datasets to 1" do
          expect { clone_dataset }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end
end
