require 'rails_helper'

describe Dataset do
  let(:dataset) {
    Dataset.create!(name: 'Ameland', country: 'nl', geo_id: 'AM31049', user: User.robot)
  }

  it "it initializes a dataset from an Atlas dataset" do
    expect(dataset).to be_a(Dataset)
  end

  it "expects a name attribute to be present" do
    expect(dataset.name).to eq("Ameland")
  end

  it 'has a base dataset' do
    expect(dataset.base_dataset).to eq 'nl'
  end

  context 'with a country not in ETsource' do
    let(:mars_dataset) do
      Dataset.new(
        name: 'Tharsis', country: 'mars', user: User.robot, geo_id: 'GM666'
      )
    end

    it 'is not valid' do
      expect(mars_dataset.valid?).to be_falsey
    end
  end

  context 'with a country in ETsource' do
    let(:ameland_dataset) do
      Dataset.new(
        name: 'Ameland', country: 'nl', user: User.robot, geo_id: 'GM3040'
      )
    end

    it 'is valid' do
      expect(ameland_dataset.valid?).to be_truthy
    end
  end

  describe '.fuzzy_search' do
    subject { described_class.fuzzy_search(query) }

    let(:eland) do
      Dataset.create!(name: 'Eland', country: 'nl', geo_id: 'AM3568', user: User.robot)
    end

    context 'with an exactly matching geo_id query' do
      let(:query) { 'AM31049' }

      it { is_expected.to include(dataset) }
      it { is_expected.to_not include(eland) }
    end

    context 'with an fuzzy matching name query' do
      let(:query) { 'land' }

      it { is_expected.to include(dataset) }
      it { is_expected.to include(eland) }
    end
  end
end
