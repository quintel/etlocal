require 'rails_helper'

describe DatasetCreator do
  it 'does not create a new dataset for a non-existing area' do
    expect {
      DatasetCreator.create('area-does-not-exist')
    }.to raise_error(ArgumentError)
  end

  it 'does not create a new dataset for an invalid area file' do
    expect {
      DatasetCreator.create('lutjebroek')
    }.to raise_error(ArgumentError)
  end

  describe "correctly create a new dataset" do
    let(:graph) {
      graph = Turbine::Graph.new

      %i(buildings_useful_demand_for_appliances
         buildings_useful_demand_cooling
         buildings_useful_demand_electricity
         buildings_useful_demand_for_space_heating
         buildings_useful_demand_light
      ).each do |key|
        graph.add(Refinery::Node.new(key, demand: 0))
      end

      graph
    }

    before do
      expect_any_instance_of(DatasetAnalyzer::Base).to receive(:graph)
        .at_least(:once)
        .and_return(graph)
    end

    it 'creates new dataset edits' do
      DatasetCreator.create('grootebroek')

      expect(Commit.count).to eq(11)
      expect(DatasetEdit.count).to eq(11)
      expect(Atlas::Dataset.find(:grootebroek).number_of_cars).to eq(30)
    end

    after { FileUtils.rm_rf("#{ Atlas.data_dir }/datasets/grootebroek") }
  end
end
