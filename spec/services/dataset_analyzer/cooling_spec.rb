require 'rails_helper'
require 'support/graph'

describe DatasetAnalyzer::Cooling do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) {
    DatasetAnalyzer::Cooling.analyze(dataset, {
      'number_of_residences' => 10,
      'percentage_of_old_residences' => 92.62
    }, households_final_demand_for_cooling_electricity: 1000)
  }

  before do
    expect_any_instance_of(DatasetAnalyzer::Base)
      .to receive(:graph).and_return(
        Graph.new("cooling").build
      )
  end

  # Cooling heatpump share
  #
  #   useful_demand = 1000 * 0.7337 * 19 = 13_940.3 MJ
  #
  #  13_940.3 MJ
  #    1145.2 MJ
  # ----------------- +
  #  15_085.5 MJ
  #
  #   (13_940.3 / 15_085.5) * 100 =~ 92.4%
  #
  it "analyzes cooling shares for cooling heat pump" do
    expect(analyzer
      .fetch(:households_cooling_heatpump_ground_water_electricity_share)
    ).to eq(92.40860428888668)
  end

  # Airconditioning share
  #
  # 100 - 92.40860428888668 =~ 7.591395711113321
  #
  it "analyzes cooling shares for airconditioning" do
    expect(analyzer
      .fetch(:households_cooling_airconditioning_electricity_share)
    ).to eq(7.591395711113321)
  end

  # Percentage of total useful demand
  #
  # 15,085.5 * 0.9262 = 13880.420395948433
  it "specifies the total old houses demand" do
    expect(analyzer
      .fetch(:households_useful_demand_for_cooling_old_houses)
    ).to eq(13972.1901) # MJ
  end

  # Percentage of total useful demand
  #
  # 15,085.5 * 0.0738 = 1105.9976519337008
  it "specifies the total new houses demand" do
    expect(analyzer
      .fetch(:households_useful_demand_for_cooling_new_houses)
    ).to eq(1113.3098999999993) # MJ
  end
end
