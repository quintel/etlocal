require 'rails_helper'
require 'support/graph'

describe GraphAssumptions do
  before do
    expect_any_instance_of(Atlas::Runner)
      .to receive(:calculate).and_return(
        Graph.new("electricity_consumption").build
      )
  end

  let(:dataset) {
    FactoryGirl.create(:dataset)
  }

  let(:commit) {
    FactoryGirl.create(:initial_commit, dataset: dataset)
  }

  let(:graph_assumptions) {
    GraphAssumptions.get(dataset)
  }

  it 'renders defaults for demands' do
    expect(graph_assumptions.fetch(:households_final_demand_electricity_demand)).to eq(
      0.0)
  end
end
