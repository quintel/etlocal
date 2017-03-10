require 'rails_helper'

describe DatasetAnalyzer::Buildings do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) { DatasetAnalyzer::Buildings.analyze(dataset, {
    building_area: 100
  }, {}) }

  # Stub graph nodes demand; every node demand = 5.0
  before do
    expect_any_instance_of(Turbine::Graph).to receive(:node)
      .at_least(:once)
      .and_return(OpenStruct.new(demand: 5.0))
  end

  it 'analyzes buildings' do
    expect(analyzer.fetch(:buildings_useful_demand_for_space_heating)
      ).to eq(9.492985997481892)
  end
end
