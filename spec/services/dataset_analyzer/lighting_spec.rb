require 'rails_helper'
require 'support/graph'

describe DatasetAnalyzer::Lighting do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzes) {
    DatasetAnalyzer::Lighting.analyze(dataset, nil, {}, {
      households_final_demand_for_lighting_electricity: 100
    })
  }

  before do
    expect_any_instance_of(DatasetAnalyzer::Base)
      .to receive(:graph).and_return(Graph.new("lighting").build)
  end

  # Total final demand of lighting = 100 MJ
  #
  # Carrier:             | Share  | Efficiency
  # -----------------------------------------------
  # LED:          100 MJ * 0.0034 * 0.5  =  0.1700 MJ
  # Fluorescent:  100 MJ * 0.8333 * 0.25 = 20.8325 MJ
  # Incandescent: 100 MJ * 0.1633 * 0.05 =  0.8165 MJ
  # -------------------------------------------------- +
  #                                        21.819  MJ
  #
  # Share percentage of LED's = (0.17 / 21.819) * 100 =~ 0.779%
  it "turns lighting to shares" do
    expect(analyzes.fetch(:households_lighting_led_electricity_share)
      ).to eq(0.7791374490123287) # MJ
  end
end
