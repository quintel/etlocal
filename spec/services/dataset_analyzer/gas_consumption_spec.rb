require 'rails_helper'
require 'support/graph'

describe DatasetAnalyzer::GasConsumption do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) {
    DatasetAnalyzer::GasConsumption.analyze(dataset, nil, {
      'gas_consumption'      => 500,
      'number_of_residences' => 100
    }, {})
  }

  before do
    expect_any_instance_of(DatasetAnalyzer::GasConsumption)
      .to receive(:graph).and_return(Graph.new("gas_consumption").build)
  end

  # Households cooker network gas (FD)
  #
  #   total_demand_gas = 500 * 100 * 31.4 = 1_570_000 MJ
  #
  #   1_570_000 * 0.0214 = 33_598 MJ
  #
  it 'determines the gas consumption for cooking' do
    expect(analyzer.fetch(:households_final_demand_for_cooking_network_gas)).to eq(33598.0)
  end

  # Water heater gas final demand
  #
  #   total_demand_gas = 500 * 100 * 31.4 = 1_570_000 MJ
  #
  #   1_570_000 * 0.1957 = 307_249 MJ
  #
  it 'determines the gas consumption for water heater' do
    expect(analyzer
      .fetch(:households_final_demand_for_hot_water_network_gas)).to eq(307249.0)
  end

  # Soace heater gas final demand
  #
  #   total_demand_gas = 500 * 100 * 31.4 = 1_570_000 MJ
  #
  #   1_570_000 * 0.7829 = 1_229_153.0 MJ
  #
  it 'determines the gas consumption for space heater' do
    expect(analyzer
      .fetch(:households_final_demand_for_space_heating_network_gas)).to eq(1229153.0)
  end
end
