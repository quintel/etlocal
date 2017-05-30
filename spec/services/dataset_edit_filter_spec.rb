require 'rails_helper'

describe DatasetEditFilter do
  let(:dataset) { FactoryGirl.create(:dataset) }
  let(:filter)  { DatasetEditFilter.new(dataset, commit) }

  describe "filters dataset edits" do
    let(:commit) {
      FactoryGirl.build(:commit, dataset_edits: [
        FactoryGirl.build(:dataset_edit, key: 'electricity_consumption', value: 1200)
      ])
    }

    it 'filters properly' do
      expect(filter.changed_edits.size).to eq(1)
    end
  end

  describe "filters boolean values correctly" do
    let(:commit) { FactoryGirl.build(:commit, dataset_edits: [
      FactoryGirl.build(:dataset_edit, key: 'has_industry', value: 1)
    ]) }

    it "filters out the has_industry" do
      expect(filter.changed_edits).to eq([])
    end
  end
end
