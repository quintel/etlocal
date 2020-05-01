require 'rails_helper'

describe Dataset do
  let(:dataset) {
    Dataset.new(name: "Ameland", country: 'nl')
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
end
