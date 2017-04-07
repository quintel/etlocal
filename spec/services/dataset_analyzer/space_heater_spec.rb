require 'rails_helper'
require 'support/graph'

RSpec.describe DatasetAnalyzer::SpaceHeater do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) {
    DatasetAnalyzer::SpaceHeater.analyze(dataset, {
      'number_of_residences' => 10,
      'percentage_of_old_residences' => 92.62
    }, {
      households_final_demand_for_space_heating_electricity: 100,
      households_final_demand_for_space_heating_network_gas: 100
    })
  }

  before do
    expect_any_instance_of(DatasetAnalyzer::Base)
      .to receive(:graph).at_least(:once).and_return(
        Graph.new('space_heater').build
      )

    expect_any_instance_of(DatasetAnalyzer::Heater)
      .to receive(:carriers).at_least(:once).and_return(
        %w(electricity network_gas steam_hot_water)
      )
  end

  it 'fetches the households space heater combined network gas useful demand' do
    expect(analyzer.fetch(:households_space_heater_combined_network_gas_share)).to eq(21.166995093436313)
  end

  it 'fetches the households space heater combined network gas useful demand' do
    expect(analyzer.fetch(:households_space_heater_hybrid_heatpump_air_water_electricity_share)).to eq(9.928848213931467)
  end
end
