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

    describe "#calculate" do
      let(:dataset) { FactoryGirl.create(:dataset) }

      describe "faulty" do
        it 'and gives a json error' do
          post :calculate, params: { dataset_area: dataset.geo_id }

          expect(JSON.parse(response.body)).to eq({
            "error" => "missing attributes electricity_consumption, gas_consumption, number_of_residences_with_solar_pv, percentage_of_old_residences, roof_surface_available_for_pv, building_area for analyzes"})
        end
      end

      describe "correctly" do
        before do
          graph = Graph.new("dataset_analyzer_base").build

          ANALYZER_STUBS.each do |analyzer|
            expect_any_instance_of(analyzer).to receive(:graph).at_least(:once).and_return(graph)
          end
        end

        let!(:create_edits) {
          FactoryGirl.create(:initial_commit, dataset: dataset)
        }

        it 'and returns a set of initializer inputs' do
          post :calculate, params: { dataset_area: dataset.geo_id }

          expect(JSON.parse(response.body)).to eq({})
        end
      end
    end
  end
end
