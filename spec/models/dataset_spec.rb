require 'rails_helper'

describe Dataset do
  let(:dataset) {
    Dataset.new(Atlas::Dataset::Derived.find("ameland"))
  }

  it "it initializes a dataset from an Atlas dataset" do
    expect(dataset).to be_a(Dataset)
  end

  it "expects an area attribute to be present" do
    expect(dataset.area).to eq("ameland")
  end
end
