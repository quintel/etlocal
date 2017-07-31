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
          post :calculate, params: {
            dataset_area: dataset.geo_id,
            calculate: { edits: JSON.dump({ test: 1 }) }
          }, format: :js

          expect(controller.instance_variable_get(:"@error").message).to include("missing attributes")
        end
      end

      describe "correctly" do
        before do
          graph = Graph.new("dataset_analyzer_base").build

          expect_any_instance_of(Atlas::Runner).to receive(:calculate).and_return(graph)
        end

        let(:commit) {
          FactoryGirl.create(:initial_commit, dataset: dataset)
        }

        let(:edits) {
          commit.dataset_edits.reduce({}) do |object, edit|
            object[edit.key] = edit.value
            object
          end
        }

        it 'and returns a set of initializer inputs' do
          post :calculate, params: {
            dataset_area: dataset.geo_id,
            calculate: { edits: JSON.dump(edits) },
          }, format: 'js'

          expect(controller.instance_variable_get(:"@analyzes")).to eq({
            number_of_cars: 1.0,
            number_of_residences: 1.0,
            number_of_inhabitants: 1.0,
            number_of_new_residences: 0.99,
            number_of_old_residences: 0.01,
            buildings_roof_surface_available_for_pv: 0,
            residences_roof_surface_available_for_pv: 1.0e-06,
            init: {
              agriculture_useful_demand_electricity: 0,
              industry_useful_demand_for_chemical_aggregated_industry: 0
            }
          })
        end
      end
    end
  end
end
