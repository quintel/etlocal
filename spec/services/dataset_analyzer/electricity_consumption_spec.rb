require 'rails_helper'
require 'support/graph'

describe DatasetAnalyzer::ElectricityConsumption do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzes) {
    DatasetAnalyzer::ElectricityConsumption.analyze(
      dataset,
      { 'electricity_consumption' => 138.8888888888, 'number_of_residences' => 100 }, {}
    )
  }

  before do
    expect_any_instance_of(DatasetAnalyzer::Base)
      .to receive(:graph).and_return(
        Graph.new("electricity_consumption").build
      )
  end


  # total electricity consumption =
  #
  #   138.88888888888 kWh * 3.6 =~ 500 MJ * 100 = 50.000 MJ
  #
  # Appliances part assuming that share is 0.6392
  #
  #   50.000 MJ * 0.6392 = 31959.99999 MJ
  it 'analyzes total final demand for appliances' do
    expect(analyzes.fetch(:households_final_demand_for_appliances_electricity)).to eq(31959.999999979544) # MJ
  end
end
