require 'rails_helper'
require 'support/graph'

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
    let(:graph) { Graph.new("dataset_analyzer_base").build }

    before do
      ANALYZER_STUBS.each do |analyzer|
        expect_any_instance_of(analyzer).to receive(:graph).at_least(:once).and_return(graph)
      end
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
