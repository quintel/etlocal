require 'rails_helper'

describe DatasetAnalyzer::GasConsumption do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) {
    DatasetAnalyzer::GasConsumption.analyze(dataset,
      {
        'gas_consumption' => 500,
        'number_of_residences' => 100
      }, {
      cooking: 500
    })
  }

  # Households cooker network gas (UD)
  #
  #   total_final_demand_cooking = 500 MJ
  #   ratio_cooking_electricity  = 28.3
  #   ratio_cooking_gas          = 71.7
  #   efficiency_cooking_gas     = 0.4
  #
  #   (500 / 28.3) * 71.7 * 0.4 = 506.71 MJ
  #
  it 'determines the gas consumption for cooking' do
    expect(analyzer.fetch(:households_cooker_network_gas)).to eq(506.71378091872793)
  end

  # Water heater gas final demand
  #
  #   total_demand_gas = 500 * 100 * 31.4 = 1_570_000 MJ
  #
  #   1_570_000 - 506.71 = 1_569_493.29 * 0.2 = 313_898.658 MJ
  #
  it 'determines the gas consumption for water heater' do
    expect(analyzer
      .fetch(:households_water_heater_combined_network_gas)).to eq(313898.6572438163)
  end

  # Soace heater gas final demand
  #
  #   total_demand_gas = 500 * 100 * 31.4 = 1_570_000 MJ
  #
  #   1_570_000 - 506.71 = 1_569_493.29 * 0.8 = 1_255_594.632 MJ
  #
  it 'determines the gas consumption for space heater' do
    expect(analyzer
      .fetch(:households_space_heater_combined_network_gas)).to eq(1255594.6289752652)
  end
end
