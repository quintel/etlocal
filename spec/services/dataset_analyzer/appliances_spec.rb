require 'rails_helper'
require 'support/graph'

describe DatasetAnalyzer::Appliances do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }

  let(:analyzes) {
    DatasetAnalyzer::Appliances.analyze(dataset, nil, {}, {
      households_final_demand_for_appliances_electricity: 100
    })
  }

  before do
    expect_any_instance_of(DatasetAnalyzer::Appliances)
      .to receive(:graph).and_return(Graph.new("appliances").build)
  end

  # Total final demand of appliances = 100 MJ
  # efficiencies of appliances are always 1.0
  #
  # useful demand of a dishwasher = 100 MJ * 0.0806 = 8.06 MJ
  it 'analyzes appliances' do
    expect(analyzes.fetch(:households_useful_demand_electric_appliances_dishwasher)).to eq(8.06) # MJ
  end
end
