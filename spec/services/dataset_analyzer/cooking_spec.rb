require 'rails_helper'

describe DatasetAnalyzer::Cooking do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzes) {
    DatasetAnalyzer::Cooking.analyze(dataset, {}, {
      households_cooker_network_gas: 100,
      cooking: 1000
    })
  }

  # Total final demand of cooking = 1000 MJ
  #                                  | Useful demand
  #  --------------------------------|---------------
  #  Resistive: 1000 * 0.097 * 0.55  |  53.35 MJ
  #  Halogen:   1000 * 0.713 * 0.6   | 427.8  MJ
  #  Induction: 1000 * 0.188 * 0.85  | 159.8  MJ
  #  Gas:       100                  | 100    MJ
  #  --------------------------------|--------------- +
  #                                  | 740.95 MJ
  #
  # households_cooker_network_gas: (100 / 740.95) * 100 =~ 13.47
  #

  it "determines the shares for all cooking carriers" do
    expect(
      analyzes.fetch(:households_cooker_network_gas_share)
    ).to eq(13.47164219318335)
  end
end
