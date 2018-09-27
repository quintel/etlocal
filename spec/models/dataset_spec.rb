require 'rails_helper'

describe Dataset do
  let(:dataset) {
    Dataset.new(name: "Ameland")
  }

  it "it initializes a dataset from an Atlas dataset" do
    expect(dataset).to be_a(Dataset)
  end

  it "expects a name attribute to be present" do
    expect(dataset.name).to eq("Ameland")
  end
end
