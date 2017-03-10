require 'rails_helper'

describe DatasetAnalyzer::Cooling do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) {
    DatasetAnalyzer::Cooling.analyze(dataset, {
      'number_of_residences' => 10,
      'percentage_of_old_residences' => 92.62
    }, cooling: 1000)
  }

  # Cooling heatpump share
  #
  #   useful_demand = 10 * 73.2427869858809 * 19 = 13_916.129527 MJ
  #
  #   13916.129527 MJ
  #    1070.288520 MJ
  # ----------------- +
  #   14986.418047 MJ
  #
  #   (13916.129527 / 14986.418047) * 100 =~ 92.86%
  #
  it "analyzes cooling shares for cooling heat pump" do
    expect(analyzer
      .fetch(:households_cooling_heatpump_ground_water_electricity_share)
    ).to eq(92.85827662657512)
  end

  # Airconditioning share
  #
  #   useful_demand = (1000 - (10 * 73.2427869858809)) * 4.0 = 1070.2885206 MJ
  #
  #   (1070.2885206 / 14986.418047) * 100 =~ 7.1417%
  #
  it "analyzes cooling shares for airconditioning" do
    expect(analyzer
      .fetch(:households_cooling_airconditioning_electricity_share)
    ).to eq(7.141723373424886)
  end

  # Percentage of total useful demand
  #
  # 14986.418047 * 0.9262 = 13880.420395948433
  it "specifies the total old houses demand" do
    expect(analyzer
      .fetch(:households_useful_demand_for_cooling_old_houses)
    ).to eq(13880.420395948433) # MJ
  end

  # Percentage of total useful demand
  #
  # 14986.418047 * 0.0738 = 1105.9976519337008
  it "specifies the total new houses demand" do
    expect(analyzer
      .fetch(:households_useful_demand_for_cooling_new_houses)
    ).to eq(1105.9976519337008) # MJ
  end
end
