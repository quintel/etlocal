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
    before(:all) { DatasetCreator.create('grootebroek') }

    it 'creates new dataset edits' do
      expect(DatasetEdit.count).to eq(7)
    end

    it 'creates an equal amount of commits' do
      expect(Commit.count).to eq(7)
    end

    it 'has the amount of cars as specified' do
      expect(Atlas::Dataset.find(:grootebroek).number_of_cars).to eq(30)
    end

    after(:all) { FileUtils.rm_rf("#{ Atlas.data_dir }/datasets/grootebroek") }
  end
end
